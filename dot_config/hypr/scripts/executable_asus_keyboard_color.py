#!/usr/bin/env python3
"""G614PH factory static colour; standard-library only, no daemon."""
import fcntl
import os
from pathlib import Path
import re
import sys


def feature(fd, packet):
    request = (3 << 30) | (len(packet) << 16) | (ord('H') << 8) | 6
    fcntl.ioctl(fd, request, packet)


def find_interfaces():
    if Path('/sys/class/dmi/id/board_name').read_text().strip() != 'G614PH':
        raise RuntimeError('Unsupported laptop model')
    controls, colours = [], []
    control_pattern = bytes.fromhex('85060970a10209711500250175089501b102')
    colour_pattern = bytes.fromhex('855d19002aff00150026ff007508951f810019002aff00150026ff007508953fb10019002aff00150026ff007508953f9102')
    for node in Path('/sys/class/hidraw').glob('hidraw*'):
        device = node / 'device'
        if 'HID_ID=0003:00000B05:000019B6' not in (device / 'uevent').read_text().splitlines():
            continue
        descriptor = (device / 'report_descriptor').read_bytes()
        if control_pattern in descriptor:
            controls.append(Path('/dev') / node.name)
        if colour_pattern in descriptor:
            colours.append(Path('/dev') / node.name)
    if len(controls) != 1 or len(colours) != 1:
        raise RuntimeError('Expected verified ASUS control and colour interfaces')
    return controls[0], colours[0]


def set_colour(hex_colour):
    control, colour = find_interfaces()
    fd = os.open(control, os.O_RDWR | os.O_CLOEXEC)
    try:
        # Report 6 is LampArrayControl (usage 0x70), not range-update report 5.
        feature(fd, bytes([6, 1]))  # Autonomous/factory lighting mode.
    finally:
        os.close(fd)
    effect = bytearray(64)
    effect[:9] = bytes([0x5d, 0xb3, 0, 0, *bytes.fromhex(hex_colour), 0xeb, 0])
    fd = os.open(colour, os.O_WRONLY | os.O_CLOEXEC)
    try:
        for packet in (bytes(effect), bytes([0x5d, 0xb5]) + bytes(62), bytes([0x5d, 0xb4]) + bytes(62)):
            if os.write(fd, packet) != len(packet):
                raise OSError('Incomplete colour report')
    finally:
        os.close(fd)


if __name__ == '__main__':
    if len(sys.argv) != 2 or not re.fullmatch(r'#?[0-9a-fA-F]{6}', sys.argv[1]):
        raise SystemExit('Expected RRGGBB')
    try:
        set_colour(sys.argv[1].lstrip('#'))
    except (OSError, RuntimeError) as exc:
        print(f'ASUS keyboard colour: {exc}', file=sys.stderr)
        sys.exit(1)
