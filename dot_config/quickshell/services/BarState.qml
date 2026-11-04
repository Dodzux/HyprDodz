pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: state
    readonly property var edges: ["top", "bottom", "left", "right"]
    property string edge: "top"
    readonly property bool vertical: edge === "left" || edge === "right"
    property bool ready: false
    property bool moving: false
    property string nextEdge: "top"
    readonly property bool notificationAtBottom: edge === "bottom"
    readonly property bool notificationAtLeft: edge === "left"
    readonly property real notificationTop: edge === "top" ? 74 : 16
    readonly property real notificationBottom: edge === "bottom" ? 74 : 16
    readonly property real notificationSide: vertical ? 92 : 16
    readonly property int notificationOrigin: edge === "bottom" ? Item.BottomRight : edge === "left" ? Item.TopLeft : Item.TopRight
    readonly property int popupGravity: edge === "bottom" ? Edges.Top : edge === "left" ? Edges.Right : edge === "right" ? Edges.Left : Edges.Bottom
    property var notificationWidgets: ({})
    function registerNotificationWidget(scr, bar, item) {
        if (!scr) return;
        var next = Object.assign({}, notificationWidgets);
        next[scr.name] = {bar: bar, item: item}; notificationWidgets = next;
    }
    function unregisterNotificationWidget(scr, item) {
        if (!scr || !notificationWidgets[scr.name] || notificationWidgets[scr.name].item !== item) return;
        var next = Object.assign({}, notificationWidgets); delete next[scr.name]; notificationWidgets = next;
    }
    function notificationPoint(scr) {
        if (!scr) return null;
        var holder = notificationWidgets[scr.name];
        if (!holder || !holder.bar || !holder.item) return null;
        // Track ancestor geometry so tray changes and edge relocation update the anchor.
        var geometry = 0;
        for (var node = holder.item; node && node !== holder.bar.contentItem; node = node.parent)
            geometry += node.x + node.y + node.width + node.height;
        if (!isFinite(geometry)) return null;
        var p = holder.item.mapToItem(holder.bar.contentItem, holder.item.width / 2, holder.item.height / 2);
        return {x: holder.bar.screenX + p.x, y: holder.bar.screenY + p.y};
    }
    function notificationX(scr, width) {
        var p = notificationPoint(scr);
        return panelX(scr ? scr.width : 1920, width, "end", p ? p.x : undefined);
    }
    function notificationY(scr, height) {
        var p = notificationPoint(scr);
        return panelY(scr ? scr.height : 1200, height, "end", p ? p.y : undefined);
    }
    function popupX(width) { return edge === "left" ? width + 14 : edge === "right" ? -14 : width / 2; }
    function popupY(height) { return edge === "top" ? height + 14 : edge === "bottom" ? -14 : height / 2; }
    function clamp(value, span, size) { return Math.max(14, Math.min(span - size - 14, value)); }
    function panelX(span, size, alignment, point) {
        var pos = edge === "left" ? 90 : edge === "right" ? span - size - 90
            : point !== undefined && point >= 0 ? point - size / 2
            : alignment === "center" ? (span - size) / 2 : span - size - 16;
        return clamp(pos, span, size);
    }
    function panelY(span, size, alignment, point) {
        var pos = edge === "top" ? 70 : edge === "bottom" ? span - size - 70
            : point !== undefined && point >= 0 ? point - size / 2
            : alignment === "center" ? 14 : span - size - 16;
        return clamp(pos, span, size);
    }
    function save() {
        if (ready) storage.setText(JSON.stringify({edge: edge}) + "\n");
    }
    function moveTo(value) {
        if (!ready || edges.indexOf(value) < 0 || (moving ? nextEdge === value : edge === value)) return;
        nextEdge = value;
        moving = true;
        settle.stop();
        relocate.restart();
    }
    Timer {
        id: relocate
        interval: 160
        onTriggered: { state.edge = state.nextEdge; state.save(); settle.restart(); }
    }
    Timer { id: settle; interval: 32; onTriggered: state.moving = false }
    FileView {
        id: storage
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/hypr/bar-placement.json"
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                var saved = JSON.parse(text());
                if (state.edges.indexOf(saved.edge) >= 0) state.edge = saved.edge;
                else console.warn("Unknown saved bar placement; using Top.");
            } catch (error) { console.warn("Unreadable bar placement; using Top."); }
            state.ready = true;
        }
        onLoadFailed: error => {
            state.ready = true;
            if (error !== FileViewError.FileNotFound) console.warn("Could not read bar placement; using Top.");
        }
    }
}
