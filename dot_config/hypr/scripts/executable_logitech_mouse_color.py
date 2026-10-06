#!/usr/bin/env python3
"""One-shot G305 colour update using HID++ 0x8070; standard library only.

Protocol reference: OpenRGB LogitechHIDPP20Controller, SetSWControl and
SetZoneEffect (0x8070 path). No receiver discovery loop or background process.
"""
import json
import os
from pathlib import Path
import re
import select
import sys
import time

SW_ID = 0x0E


def metadata(device):
    return dict(line.split('=', 1) for line in (device / 'uevent').read_text().splitlines() if '=' in line)


def find_mouse():
    mice = []
    for device in Path('/sys/bus/hid/devices').glob('*'):
        info = metadata(device)
        if info.get('HID_ID') == '0003:0000046D:00004074' and info.get('HID_NAME') == 'Logitech G305':
            physical, slot = info['HID_PHYS'].rsplit(':', 1)
            if slot.isdecimal() and 1 <= int(slot) <= 6:
                mice.append((physical, int(slot), device.name + ':' + info.get('HID_UNIQ', '')))
    endpoints = []
    for node in Path('/sys/class/hidraw').glob('hidraw*'):
        device = node / 'device'
        info = metadata(device)
        if info.get('HID_ID') != '0003:0000046D:0000C53F':
            continue
        descriptor = (device / 'report_descriptor').read_bytes()
        # HID++ short and long input/output collections (reports 0x10, 0x11).
        if bytes.fromhex('851095067508') not in descriptor or bytes.fromhex('851195137508') not in descriptor:
            continue
        for physical, slot, identity in mice:
            if info.get('HID_PHYS') == physical:
                endpoints.append((Path('/dev') / node.name, slot, str(device.resolve()) + ':' + identity))
    if len(endpoints) != 1:
        raise RuntimeError('Expected one verified G305 receiver endpoint')
    return endpoints[0]


class HIDPP:
    def __init__(self, fd, slot):
        self.fd, self.slot = fd, slot

    def request(self, feature, function, payload=b''):
        try:
            return self.request_once(feature, function, payload)
        except TimeoutError:
            # These queries/static writes are idempotent. One bounded retry
            # covers the first packet lost while the wireless mouse wakes.
            return self.request_once(feature, function, payload)

    def request_once(self, feature, function, payload=b''):
        if len(payload) > 16:
            raise ValueError('HID++ payload too long')
        size = 7 if len(payload) <= 3 else 20
        command = function | SW_ID
        packet = bytes([0x10 if size == 7 else 0x11, self.slot, feature, command]) + payload
        packet = packet.ljust(size, b'\0')
        if os.write(self.fd, packet) != size:
            raise OSError('Incomplete mouse report')
        deadline = time.monotonic() + 0.5
        while time.monotonic() < deadline:
            ready, _, _ = select.select([self.fd], [], [], max(0, deadline - time.monotonic()))
            if not ready:
                break
            try:
                reply = os.read(self.fd, 64)
            except BlockingIOError:
                continue
            if len(reply) < 7 or reply[0] not in (0x10, 0x11) or reply[1] != self.slot:
                continue
            if reply[2] == 0xFF and reply[3:5] == bytes([feature, command]):
                raise RuntimeError(f'Mouse rejected HID++ command: {reply[5]:02x}')
            if reply[2:4] == bytes([feature, command]):
                return reply[4:]
        raise TimeoutError('Mouse did not acknowledge colour command')


def verified_index(mouse, identity, cache):
    # Kernel receiver/device instances and the paired mouse ID form the key.
    # Reconnects or re-pairing invalidate it; runtime storage resets at login.
    try:
        saved = json.loads(cache.read_text())
        if saved.get('identity') == identity and saved.get('schema') == 1:
            index = saved.get('index')
            if type(index) is int and 1 <= index <= 254:
                return index
    except (OSError, ValueError, AttributeError):
        pass
    feature_info = mouse.request(0, 0, bytes.fromhex('8070'))
    index = feature_info[0]
    if not index or feature_info[2] != 6:
        raise RuntimeError('Expected verified 0x8070 V6 colour feature')
    if mouse.request(index, 0)[0] != 1:
        raise RuntimeError('Expected one mouse lighting zone')
    effect = mouse.request(index, 0x20, bytes([0, 1, 0, 0]))
    if effect[:4] != bytes([0, 1, 0, 1]):
        raise RuntimeError('Mouse static effect layout differs')
    try:
        temporary = cache.with_name(cache.name + f'.{os.getpid()}.tmp')
        temporary.write_text(json.dumps({'schema': 1, 'identity': identity, 'index': index}))
        os.replace(temporary, cache)
    except OSError:
        pass  # Cache is optional; colour updates still work.
    return index


def set_colour(hex_colour):
    endpoint, slot, identity = find_mouse()
    cache = Path(os.environ.get('XDG_RUNTIME_DIR', '/tmp')) / 'wallpaper-rgb.mouse.capabilities.json'
    fd = os.open(endpoint, os.O_RDWR | os.O_NONBLOCK | os.O_CLOEXEC)
    try:
        mouse = HIDPP(fd, slot)
        index = verified_index(mouse, identity, cache)
        mouse.request(index, 0x80, bytes([1, 1]))
        rgb = bytes.fromhex(hex_colour)
        # Zone 0, static effect 1, RGB, fixed-colour marker; volatile colour.
        mouse.request(index, 0x30, (bytes([0, 1]) + rgb + bytes([2 if any(rgb) else 0])).ljust(16, b'\0'))
    finally:
        os.close(fd)


if __name__ == '__main__':
    if len(sys.argv) != 2 or not re.fullmatch(r'#?[0-9a-fA-F]{6}', sys.argv[1]):
        raise SystemExit('Expected RRGGBB')
    try:
        set_colour(sys.argv[1].lstrip('#'))
    except (OSError, RuntimeError) as exc:
        print(f'Mouse colour: {exc}', file=sys.stderr)
        sys.exit(1)
