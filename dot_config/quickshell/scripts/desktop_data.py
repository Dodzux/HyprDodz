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
    aliases = {"brave": "brave-browser", "neovim": "nvim", "herdr": "herdr-app"}
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


def monitor_work_area(monitor):
    """Logical desktop rectangle, excluding layer-shell reserved margins."""
    scale = monitor.get("scale", 1) or 1
    width, height = monitor["width"] / scale, monitor["height"] / scale
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    reserved = list(monitor.get("reserved") or [])
    reserved = (reserved + [0, 0, 0, 0])[:4]
    left, top, right, bottom = (max(0, float(v)) for v in reserved)
    return {"x": monitor.get("x", 0) + left, "y": monitor.get("y", 0) + top,
            "width": max(1, width - left - right), "height": max(1, height - top - bottom)}


def workspaces():
    monitors = {m["id"]: m for m in hypr_json("monitors")}
    result = []
    for client in hypr_json("clients"):
        workspace = client.get("workspace") or {}
        try:
            number = int(workspace.get("id", workspace.get("name", "0")))
        except (TypeError, ValueError):
            continue
        if not client.get("mapped") or client.get("hidden") or number < 1:
            continue
        monitor = monitors.get(client["monitor"])
        if not monitor:
            continue
        area = monitor_work_area(monitor)
        width, height = area["width"], area["height"]
        # App identity and rectangles suffice: no screenshots or document titles.
        result.append({"address": client["address"], "pid": client["pid"], "class": client["class"], "aspect": width / height,
                       "workspace": str(client["workspace"]["name"]),
                       "x": max(0, min(1, (client["at"][0] - area["x"]) / width)),
                       "y": max(0, min(1, (client["at"][1] - area["y"]) / height)),
                       "w": max(0, min(1, (client["at"][0] + client["size"][0] - area["x"]) / width) - max(0, (client["at"][0] - area["x"]) / width)),
                       "h": max(0, min(1, (client["at"][1] + client["size"][1] - area["y"]) / height) - max(0, (client["at"][1] - area["y"]) / height))})
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
    monitors = [dict(m, workArea=monitor_work_area(m)) for m in hypr_json("monitors")]
    return {"monitors": monitors, "workspaces": hypr_json("workspaces"),
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


def wallpaper_assets(cache, directory=None):
    """Publish the cheap inventory first, then fill immutable preview assets."""
    directory = directory or HOME / "Pictures/Wallpapers"
    extractor = HOME / ".config/hypr/scripts/sync_border.py"
    cache.mkdir(parents=True, exist_ok=True)
    paths = [p for p in directory.iterdir() if p.is_file()
             and p.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp", ".gif"}]
    paths.sort(key=lambda p: (re.sub(r"^\d+[\s._-]+", "", p.name.casefold()), p.name.casefold(), str(p)))
    inventory, missing = [], []
    for path in paths:
        stat = path.stat()
        source_id = f"{path.resolve()}:{stat.st_mtime_ns}:{stat.st_size}"
        identity = f"{source_id}:{extractor.stat().st_mtime_ns}:v1"
        palette_file = cache / (hashlib.sha256(identity.encode()).hexdigest() + ".json")
        preview_version = ":384x216-gif-rgb-v2" if path.suffix.lower() == ".gif" else ":384x216-v1"
        thumbnail = cache / ("thumb-" + hashlib.sha256((source_id + preview_version).encode()).hexdigest() + ".jpg")
        palette = None
        try:
            saved = json.loads(palette_file.read_text())
            if isinstance(saved, dict) and saved.get("identity") == identity and all(k in saved for k in ("accent", "swatches")):
                palette = saved
        except (OSError, ValueError, TypeError):
            pass
        item = {"path": str(path), "name": path.name,
                "accent": palette["accent"] if palette else "#e5e5e5",
                "swatches": palette["swatches"] if palette else [],
                "thumbnail": thumbnail.as_uri() if thumbnail.is_file() else ""}
        inventory.append(item)
        if not item["thumbnail"] or palette is None:
            missing.append((path, item, thumbnail, palette_file, identity, palette))
    yield {"type": "list", "items": inventory}

    def build(job):
        path, item, thumbnail, palette_file, identity, palette = job
        result = dict(item)
        try:
            from PIL import Image, ImageOps, ImageStat
            if not thumbnail.is_file():
                with Image.open(path) as original:
                    original.seek(0)  # Animated wallpaper previews stay static.
                    # Palette images otherwise force nearest-neighbour resizing.
                    image = ImageOps.exif_transpose(original).convert("RGB")
                    image.thumbnail((384, 216), Image.Resampling.BILINEAR, reducing_gap=3.0)
                    if original.format == "GIF":
                        brightness = sum(ImageStat.Stat(image).mean) / 3
                        if brightness < 1.5:
                            for frame in (1, 4, 8, 12, 16, 24):
                                try:
                                    original.seek(frame)
                                except EOFError:
                                    break
                                candidate = original.convert("RGB")
                                candidate.thumbnail((384, 216), Image.Resampling.BILINEAR, reducing_gap=3.0)
                                candidate_brightness = sum(ImageStat.Stat(candidate).mean) / 3
                                if candidate_brightness > brightness:
                                    image, brightness = candidate, candidate_brightness
                                if brightness >= 3:
                                    break
                    temporary = None
                    try:
                        with tempfile.NamedTemporaryFile(dir=cache, suffix=".jpg", delete=False) as stream:
                            temporary = Path(stream.name)
                            image.save(stream, format="JPEG", quality=84)
                        os.replace(temporary, thumbnail)
                    finally:
                        if temporary is not None:
                            temporary.unlink(missing_ok=True)
            result["thumbnail"] = thumbnail.as_uri()
            if palette is None:
                spec = importlib.util.spec_from_file_location("desktop_color_reader", extractor)
                reader = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(reader)
                accent, _ = reader.extract_color(str(path))
                with Image.open(path) as original:
                    original.seek(0)
                    image = original.convert("RGB")
                    image.thumbnail((96, 96))
                    quantized = image.quantize(colors=6)
                    colors = quantized.getpalette()
                    swatches = ["#" + "".join(f"{v:02x}" for v in colors[index * 3:index * 3 + 3])
                                for _, index in sorted(quantized.getcolors(), reverse=True)]
                result.update(accent="#" + accent, swatches=["#" + accent] + [c for c in swatches if c != "#" + accent][:4])
                saved = dict(result, identity=identity)
                temporary = None
                try:
                    with tempfile.NamedTemporaryFile(mode="w", dir=cache, delete=False) as stream:
                        json.dump(saved, stream)
                        temporary = Path(stream.name)
                    os.replace(temporary, palette_file)
                finally:
                    if temporary is not None:
                        temporary.unlink(missing_ok=True)
        except (OSError, ValueError, KeyError) as error:
            result["error"] = str(error)
        return result

    # Bound peak decode memory and CPU, and let Qt show each preview as it arrives.
    if missing:
        from concurrent.futures import ThreadPoolExecutor, as_completed
        with ThreadPoolExecutor(max_workers=2) as pool:
            for future in as_completed([pool.submit(build, job) for job in missing]):
                yield {"type": "asset", "item": future.result()}
    yield {"type": "done"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["shortcuts", "workspaces", "palettes", "wallpapers", "overview", "overview-action", "focus-window"])
    parser.add_argument("--cache", type=Path, default=HOME / ".cache/quickshell/wallpaper-palettes")
    parser.add_argument("--request", help="Validated overview action as JSON")
    args = parser.parse_args()
    if args.mode == "wallpapers":
        try:
            for update in wallpaper_assets(args.cache):
                print(json.dumps(update), flush=True)
        except (ValueError, OSError) as error:
            print(json.dumps({"type": "error", "message": str(error)}), flush=True)
        return
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
