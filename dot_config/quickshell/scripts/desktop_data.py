#!/usr/bin/env python3
"""Read desktop metadata and cache wallpaper palettes; never apply desktop changes."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

HOME = Path.home()


def hypr_json(kind):
    result = subprocess.run(["hyprctl", kind, "-j"], capture_output=True, text=True, timeout=3, check=True)
    return json.loads(result.stdout)


def shortcuts():
    aliases = {"brave": "brave-browser", "neovim": "nvim"}
    result = {}
    for bind in hypr_json("binds"):
        description = bind.get("description", "")
        if not description.startswith("Apps: "):
            continue
        title = description[6:]
        match = re.search(r"\(([^)]+)\)$", title)
        name = (match[1] if match else title).lower()
        modifiers = [label for bit, label in [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")] if bind["modmask"] & bit]
        result[aliases.get(name, name)] = "+".join(modifiers + [bind["key"].upper()])
    return result


def workspaces():
    monitors = {m["id"]: m for m in hypr_json("monitors")}
    result = []
    for client in hypr_json("clients"):
        if not client.get("mapped") or client.get("hidden") or client["workspace"]["id"] < 1:
            continue
        monitor = monitors.get(client["monitor"])
        if not monitor:
            continue
        width, height = monitor["width"] / monitor["scale"], monitor["height"] / monitor["scale"]
        if monitor.get("transform", 0) % 2:
            width, height = height, width
        # App identity and rectangles suffice: no screenshots or document titles.
        result.append({"address": client["address"], "pid": client["pid"], "class": client["class"], "aspect": width / height,
                       "workspace": str(client["workspace"]["name"]),
                       "x": max(0, min(1, (client["at"][0] - monitor["x"]) / width)),
                       "y": max(0, min(1, (client["at"][1] - monitor["y"]) / height)),
                       "w": max(0, min(1, (client["at"][0] + client["size"][0] - monitor["x"]) / width) - max(0, (client["at"][0] - monitor["x"]) / width)),
                       "h": max(0, min(1, (client["at"][1] + client["size"][1] - monitor["y"]) / height) - max(0, (client["at"][1] - monitor["y"]) / height))})
    return result


def focus_preview_window(request):
    address, pid = request.get("address"), request.get("pid")
    if not isinstance(address, str) or not re.fullmatch(r"0x[0-9a-fA-F]+", address):
        raise ValueError("Invalid window address")
    client = next((c for c in hypr_json("clients") if c.get("address") == address
                   and c.get("pid") == pid and c.get("mapped") and not c.get("hidden")), None)
    if not client:
        raise ValueError("That window has closed; hover again to refresh")
    dispatch(f'hl.dsp.focus({{window="address:{address}"}})')
    return {"ok": True}


def overview_snapshot():
    return {"monitors": hypr_json("monitors"), "workspaces": hypr_json("workspaces"),
            "clients": [c for c in hypr_json("clients")
                        if c.get("mapped") and not c.get("hidden") and c.get("workspace", {}).get("id", 0) > 0]}


def workspace_id(value):
    if isinstance(value, bool) or not isinstance(value, int) or not 1 <= value <= 100000:
        raise ValueError("Choose a numbered workspace")
    return value


def dispatch(code):
    result = subprocess.run(["hyprctl", "eval", "hl.dispatch(" + code + ")"],
                            capture_output=True, text=True, timeout=4, check=True)
    if result.stdout.strip() != "ok":
        raise ValueError(result.stdout.strip() or result.stderr.strip() or "Hyprland rejected the move")


def overview_action(request):
    """Validate native moves against fresh state; never interpolate titles or shell text."""
    before = overview_snapshot()
    kind = request.get("type")
    if kind == "move":
        address = request.get("address", "")
        if not isinstance(address, str) or not re.fullmatch(r"0x[0-9a-fA-F]+", address):
            raise ValueError("Invalid window address")
        target = workspace_id(request.get("target"))
        client = next((c for c in before["clients"] if c["address"] == address), None)
        if not client:
            raise ValueError("That window has closed or moved to a special workspace")
        source = client["workspace"]["id"]
        if source != request.get("expectedSource", source):
            raise ValueError("The window moved elsewhere; refresh before trying again")
        if source == target:
            raise ValueError("Window is already on that workspace")
        if client.get("pinned"):
            raise ValueError("Unpin the window before moving it")
        dispatch(f'hl.dsp.window.move({{workspace={target}, follow=false, window="address:{address}"}})')
        after = overview_snapshot()
        current = next((c for c in after["clients"] if c["address"] == address), None)
        if not current or current["workspace"]["id"] != target:
            raise ValueError("Hyprland did not move the window")
        undo = {"type": "move", "address": address, "target": source, "expectedSource": target}
        message = f"Moved window to workspace {target}"
    elif kind == "swap":
        source, target = workspace_id(request.get("source")), workspace_id(request.get("target"))
        if source == target:
            raise ValueError("Choose a different workspace")
        signature = sorted((c["address"], c["workspace"]["id"]) for c in before["clients"]
                           if c["workspace"]["id"] in {source, target})
        if "expected" in request and signature != [tuple(item) for item in request["expected"]]:
            raise ValueError("Workspace contents changed; undo was cancelled")
        existing = {w["id"] for w in before["workspaces"]}
        if source not in existing and target not in existing:
            raise ValueError("Both workspaces are empty")
        temporary = max([10] + [i for i in existing if i > 0]) + 1
        steps = ([(source, temporary), (target, source), (temporary, target)]
                 if source in existing and target in existing else
                 [(source, target)] if source in existing else [(target, source)])
        completed = []
        try:
            for old, new in steps:
                dispatch(f"hl.dsp.workspace.change_id({{workspace={old}, id={new}}})")
                completed.append((old, new))
        except Exception:
            for old, new in reversed(completed):
                dispatch(f"hl.dsp.workspace.change_id({{workspace={new}, id={old}}})")
            raise
        after = overview_snapshot()
        expected = {address: target if ws == source else source for address, ws in signature}
        actual = {c["address"]: c["workspace"]["id"] for c in after["clients"]}
        if any(actual.get(address) != ws for address, ws in expected.items()):
            raise ValueError("Workspace contents changed during the swap; refresh to review")
        undo = {"type": "swap", "source": source, "target": target,
                "expected": sorted(expected.items())}
        message = f"Swapped workspaces {source} and {target}"
    else:
        raise ValueError("Unknown overview action")
    return {"ok": True, "message": message, "snapshot": after, "undo": undo}


def palettes(cache):
    from PIL import Image
    extractor = HOME / ".config/hypr/scripts/sync_border.py"
    spec = importlib.util.spec_from_file_location("desktop_color_reader", extractor)
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    cache.mkdir(parents=True, exist_ok=True)
    result = []
    for path in sorted((HOME / "Pictures/Wallpapers").iterdir(), key=lambda p: p.name.lower()):
        if not path.is_file() or path.suffix.lower() not in {".jpg", ".jpeg", ".png", ".webp", ".gif"}:
            continue
        try:
            identity = f"{path.resolve()}:{path.stat().st_mtime_ns}:{path.stat().st_size}:{extractor.stat().st_mtime_ns}:v1"
            key = hashlib.sha256(identity.encode()).hexdigest()
            target = cache / (key + ".json")
            if target.exists():
                item = json.loads(target.read_text())
                if item.get("identity") != identity:
                    raise ValueError("Stale palette cache")
            else:
                accent, _ = reader.extract_color(str(path))  # Pure extraction; no theme writes.
                with Image.open(path) as image:
                    image.seek(0)
                    image = image.convert("RGB")
                    image.thumbnail((96, 96))
                    quantized = image.quantize(colors=6)
                    palette = quantized.getpalette()
                    colors = ["#" + "".join(f"{v:02x}" for v in palette[index * 3:index * 3 + 3])
                              for _, index in sorted(quantized.getcolors(), reverse=True)]
                swatches = ["#" + accent] + [c for c in colors if c != "#" + accent][:4]
                item = {"path": str(path), "name": path.name, "accent": "#" + accent,
                        "swatches": swatches, "identity": identity}
                with tempfile.NamedTemporaryFile(mode="w", dir=cache, delete=False) as stream:
                    json.dump(item, stream)
                    temporary = stream.name
                os.replace(temporary, target)
            result.append({k: item[k] for k in ["path", "name", "accent", "swatches"]})
        except (OSError, ValueError, KeyError) as error:
            # One unreadable image does not break the picker.
            result.append({"path": str(path), "name": path.name, "accent": "#e5e5e5", "swatches": [], "error": str(error)})
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["shortcuts", "workspaces", "palettes", "overview", "overview-action", "focus-window"])
    parser.add_argument("--cache", type=Path, default=HOME / ".cache/quickshell/wallpaper-palettes")
    parser.add_argument("--request", help="Validated overview action as JSON")
    args = parser.parse_args()
    try:
        if args.mode in ("overview-action", "focus-window"):
            request = json.loads(args.request or "{}")
            if not isinstance(request, dict):
                raise ValueError("Invalid action")
            data = overview_action(request) if args.mode == "overview-action" else focus_preview_window(request)
        elif args.mode == "overview":
            data = overview_snapshot()
        else:
            data = palettes(args.cache) if args.mode == "palettes" else globals()[args.mode]()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        data = {"ok": False, "message": str(error)}
    print(json.dumps(data))


if __name__ == "__main__":
    main()
