pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

// Capture only while visible. Window and workspace moves use fresh native state.
PanelWindow {
    id: overview
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1

    property var clients: []
    property var monitors: []
    property var workspaces: []
    property int activeWs: 1
    property string selectedAddress: ""
    property string query: ""
    property string message: ""
    property bool opening: false
    property var undoRequest: null
    property bool undoing: false
    property int extraWorkspace: 0
    onOrderedWindowsChanged: {
        if (!opening && !orderedWindows.some(c => c.address === selectedAddress))
            selectedAddress = orderedWindows.length ? orderedWindows[0].address : "";
    }
    readonly property bool busy: mutation.running
    readonly property var workspaceIds: {
        var ids = [];
        clients.forEach(c => { var id = c.workspace.id; if (id > 0 && ids.indexOf(id) < 0) ids.push(id); });
        if (extraWorkspace > 0 && ids.indexOf(extraWorkspace) < 0) ids.push(extraWorkspace);
        return ids.sort((a, b) => a - b);
    }
    readonly property var orderedWindows: clients.filter(c => matches(c)).slice()
        .sort((a, b) => a.workspace.id - b.workspace.id || a.at[1] - b.at[1] || a.at[0] - b.at[0]);

    function matches(c) {
        var q = query.toLowerCase().trim();
        return !q || (c.title || "").toLowerCase().includes(q) || (c.class || "").toLowerCase().includes(q);
    }
    function applySnapshot(data) {
        if (!data.monitors || !data.clients || !data.workspaces) throw new Error("Invalid desktop snapshot");
        monitors = data.monitors;
        clients = data.clients;
        if (extraWorkspace > 0 && clients.some(c => c.workspace.id === extraWorkspace)) extraWorkspace = 0;
        workspaces = data.workspaces;
        var mon = monitors.find(m => m.focused) || monitors[0];
        activeWs = mon ? mon.activeWorkspace.id : 1;
        if (!orderedWindows.some(c => c.address === selectedAddress)) {
            var focused = orderedWindows.find(c => c.focusHistoryID === 0);
            selectedAddress = focused ? focused.address : orderedWindows.length ? orderedWindows[0].address : "";
        }
    }
    function toggle(scr) {
        if (visible || opening) { opening = false; visible = false; return; }
        if (scr) screen = scr;
        query = "";
        message = "";
        extraWorkspace = 0;
        opening = true;
        if (!fetch.running) fetch.running = true;
    }
    function addWorkspaceTarget() {
        var id = 1;
        while (workspaceIds.indexOf(id) >= 0) id++;
        extraWorkspace = id;
    }
    function windowsOn(id) { return clients.filter(c => c.workspace.id === id); }
    function monitorFor(id) { return monitors.find(m => m.id === id) || monitors[0] || null; }
    function toplevelFor(c) {
        return Hyprland.toplevels.values.find(t => t.address.replace(/^0x/, "") === c.address.replace(/^0x/, "")) || null;
    }
    function iconFor(c) {
        var entry = DesktopEntries.heuristicLookup(c.class === "org.yazi.fm" ? "yazi" : c.class || "");
        return entry && entry.icon ? (entry.icon.startsWith("/") ? entry.icon : "image://icon/" + entry.icon) : "image://icon/application-x-executable";
    }
    function focusWindow(c) {
        if (busy || !c) return;
        visible = false;
        Hyprland.dispatch('hl.dsp.focus({window="address:' + c.address + '"})');
    }
    function focusWorkspace(id) {
        if (busy) return;
        visible = false;
        Hyprland.dispatch("hl.dsp.focus({workspace=" + id + "})");
    }
    function perform(request, isUndo) {
        if (busy) return;
        undoing = isUndo === true;
        mutation.command = ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "overview-action", "--request", JSON.stringify(request)];
        mutation.running = true;
    }
    function moveWindow(c, target) {
        if (!c || c.workspace.id === target) return;
        perform({type: "move", address: c.address, target: target, expectedSource: c.workspace.id}, false);
    }
    function undoLast() { if (undoRequest && !busy) perform(undoRequest, true); }
    function selectNext(step) {
        var n = orderedWindows.length;
        if (!n) return;
        var current = orderedWindows.findIndex(c => c.address === selectedAddress);
        selectedAddress = orderedWindows[(current + step + n) % n].address;
    }

    Process {
        id: fetch
        command: ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "overview"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    overview.applySnapshot(JSON.parse(this.text));
                    if (overview.opening) { overview.opening = false; overview.visible = true; }
                } catch (error) { overview.opening = false; overview.message = "Could not refresh overview"; console.warn("Overview:", error); }
            }
        }
    }
    Process {
        id: mutation
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(this.text);
                    overview.message = result.message || "Move failed";
                    if (result.ok) {
                        overview.applySnapshot(result.snapshot);
                        overview.undoRequest = overview.undoing ? null : result.undo;
                    }
                } catch (error) { overview.message = "Could not complete move"; console.warn("Overview:", error); }
            }
        }
        onExited: if (overview.visible) refreshSoon.restart()
    }
    Timer {
        id: refreshSoon
        interval: 160
        onTriggered: if (overview.visible && !mutation.running && !fetch.running && (!content.item || !content.item.dragging)) fetch.running = true
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (overview.visible && /^(openwindow|closewindow|movewindow|workspace|createworkspace|destroyworkspace|renameworkspace|changefloatingmode|fullscreen|windowtitle)/.test(event.name))
                refreshSoon.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        MouseArea { anchors.fill: parent; onClicked: { if (!overview.busy) overview.visible = false; } }
    }
    Loader {
        id: content
        anchors.fill: parent
        active: overview.visible
        focus: true
        sourceComponent: FocusScope {
            id: stage
            focus: true
            property bool dragging: false
            property string dragKind: ""
            property var payload: null
            property point pressPoint: Qt.point(0, 0)
            property point dragPoint: Qt.point(0, 0)
            property int dropWorkspace: -1
            property bool pressedGesture: false
            readonly property int count: overview.workspaceIds.length
            readonly property int cols: count <= 4 ? Math.max(1, count) : Math.min(5, Math.ceil(count / 2))
            readonly property int rows: Math.max(1, Math.ceil(count / cols))
            readonly property real gap: 22
            readonly property real aspect: overview.height / overview.width
            readonly property real tileW: Math.max(100, Math.min(680,
                (overview.width * 0.92 - (cols - 1) * gap) / cols,
                (overview.height * 0.71 - (rows - 1) * gap - rows * 38) / rows / aspect))
            readonly property real tileH: tileW * aspect

            function begin(kind, data, area, mouse) {
                if (overview.busy) return;
                pressedGesture = true;
                dragKind = kind;
                payload = data;
                pressPoint = area.mapToItem(stage, mouse.x, mouse.y);
                dragPoint = pressPoint;
                if (kind === "window") overview.selectedAddress = data.address;
            }
            function update(area, mouse) {
                if (!pressedGesture || overview.busy) return;
                dragPoint = area.mapToItem(stage, mouse.x, mouse.y);
                if (Math.hypot(dragPoint.x - pressPoint.x, dragPoint.y - pressPoint.y) > 9) dragging = true;
                dropWorkspace = -1;
                if (!dragging) return;
                for (var i = 0; i < cards.count; i++) {
                    var card = cards.itemAtIndex(i);
                    var p = card.mapFromItem(stage, dragPoint.x, dragPoint.y);
                    if (p.x >= 0 && p.y >= 0 && p.x <= card.width && p.y <= card.height) {
                        var origin = dragKind === "window" ? payload.workspace.id : payload;
                        if (origin !== card.wsId) dropWorkspace = card.wsId;
                        break;
                    }
                }
            }
            function cancel() { pressedGesture = false; dragging = false; payload = null; dropWorkspace = -1; }
            function finish() {
                if (!pressedGesture) return;
                var wasDrag = dragging, kind = dragKind, data = payload, target = dropWorkspace;
                cancel();
                if (wasDrag) {
                    if (target < 1) return;
                    if (kind === "window") overview.moveWindow(data, target);
                    else overview.perform({type: "swap", source: data, target: target}, false);
                } else if (kind === "window") overview.focusWindow(data);
                else overview.focusWorkspace(data);
            }
            Keys.onPressed: event => {
                var shiftedNumber = (event.modifiers & Qt.ShiftModifier) ? "!@#$%^&*()".indexOf(event.text) : -1;
                if (event.key === Qt.Key_Escape) {
                    if (stage.pressedGesture) stage.cancel();
                    else if (overview.query.length) overview.query = "";
                    else overview.visible = false;
                } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Z) overview.undoLast();
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Tab) overview.selectNext(1);
                else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) overview.selectNext(-1);
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) overview.focusWindow(overview.orderedWindows.find(c => c.address === overview.selectedAddress));
                else if (shiftedNumber >= 0) overview.moveWindow(overview.clients.find(c => c.address === overview.selectedAddress), shiftedNumber + 1);
                else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9 && !(event.modifiers & Qt.ControlModifier)) {
                    var id = event.key === Qt.Key_0 ? 10 : event.key - Qt.Key_0;
                    if (event.modifiers & Qt.ShiftModifier) overview.moveWindow(overview.clients.find(c => c.address === overview.selectedAddress), id);
                    else overview.focusWorkspace(id);
                } else return;
                event.accepted = true;
            }

            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 48 }
                width: Math.min(overview.width * 0.92, 1100)
                height: 62
                radius: 14
                color: Theme.glassBg
                border.color: Theme.glassBorder
                RowLayout {
                    anchors { fill: parent; margins: 14 }
                    spacing: 16
                    Text { text: "Workspaces"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 18; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: Theme.bgSelection
                        radius: 7
                        TextInput {
                            id: search
                            anchors { fill: parent; margins: 8 }
                            color: Theme.text
                            font.family: Theme.fontMain
                            font.pixelSize: 12
                            selectByMouse: true
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.base
                            text: overview.query
                            onTextEdited: overview.query = text
                            Text { anchors.fill: parent; text: "Search windows…  /"; color: Theme.subtext0; font: parent.font; visible: !parent.text && !parent.activeFocus }
                            Keys.onEscapePressed: { overview.query = ""; stage.forceActiveFocus(); }
                            Keys.onReturnPressed: overview.focusWindow(overview.orderedWindows.find(c => c.address === overview.selectedAddress))
                            Keys.onDownPressed: { overview.selectNext(1); stage.forceActiveFocus(); }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 78; Layout.preferredHeight: 34
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                        radius: 7; color: undoHover.hovered ? Theme.launcherSelectionBg : Theme.bgSelection
                        opacity: overview.undoRequest && !overview.busy ? 1 : 0.4
                        Text { anchors.centerIn: parent; text: "↶ Undo"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 12 }
                        HoverHandler { id: undoHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { enabled: overview.undoRequest !== null && !overview.busy; onTapped: overview.undoLast() }
                    }
                    Rectangle {
                        Layout.preferredWidth: 110; Layout.preferredHeight: 34
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        radius: 7; color: addHover.hovered ? Theme.launcherSelectionBg : Theme.bgSelection
                        Text { anchors.centerIn: parent; text: "+ Workspace"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 12 }
                        HoverHandler { id: addHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { enabled: !overview.busy; onTapped: overview.addWorkspaceTarget() }
                    }
                }
            }
            Shortcut { sequence: "/"; enabled: overview.visible && !search.activeFocus; onActivated: search.forceActiveFocus() }

            GridView {
                id: cards
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: stage.gap / 2
                anchors.verticalCenterOffset: stage.gap / 2
                width: stage.cols * cellWidth
                height: stage.rows * cellHeight
                cellWidth: stage.tileW + stage.gap
                cellHeight: stage.tileH + 38 + stage.gap
                interactive: false
                clip: false
                visible: count > 0
                cacheBuffer: overview.height
                model: ScriptModel { values: overview.workspaceIds }
                populate: Transition {
                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.motionNormal }
                    NumberAnimation { properties: "scale"; from: 0.96; to: 1; duration: Theme.motionNormal; easing.type: Easing.OutCubic }
                }
                add: Transition {
                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.motionNormal }
                    NumberAnimation { properties: "scale"; from: 0.94; to: 1; duration: Theme.motionNormal; easing.type: Easing.OutCubic }
                }
                remove: Transition {
                    NumberAnimation { properties: "opacity"; to: 0; duration: Theme.motionExit }
                    NumberAnimation { properties: "scale"; to: 0.95; duration: Theme.motionExit; easing.type: Easing.InCubic }
                }
                displaced: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                move: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                    delegate: Column {
                        id: card
                        objectName: "overview-workspace-" + wsId
                        required property int modelData
                        readonly property int wsId: modelData
                        readonly property var wsWindows: overview.windowsOn(wsId)
                        readonly property bool dropHere: stage.dragging && stage.dropWorkspace === wsId
                        width: stage.tileW
                        spacing: 8
                        Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                        Rectangle {
                            width: parent.width; height: 30; radius: 7
                            Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                            color: headerHover.hovered ? Theme.bgSelection : "transparent"
                            Row {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 8 }
                                spacing: 9
                                Text { text: "⠿"; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 15 }
                                Text { text: "Workspace " + card.wsId; color: card.wsId === overview.activeWs ? Theme.accent : Theme.text; font.family: Theme.fontMain; font.pixelSize: 12; font.bold: true }
                                Text { text: card.wsWindows.length + (card.wsWindows.length === 1 ? " app" : " apps"); color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 11 }
                            }
                            HoverHandler { id: headerHover; cursorShape: Qt.OpenHandCursor }
                            MouseArea {
                                anchors.fill: parent
                                enabled: !overview.busy
                                preventStealing: true
                                onPressed: mouse => stage.begin("workspace", card.wsId, this, mouse)
                                onPositionChanged: mouse => stage.update(this, mouse)
                                onReleased: stage.finish()
                                onCanceled: stage.cancel()
                            }
                        }
                        Rectangle {
                            id: tile
                            width: stage.tileW; height: stage.tileH
                            Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                            Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                            radius: 14; antialiasing: true; clip: true
                            color: card.dropHere ? Theme.launcherSelectionBg : Theme.glassBg
                            border.color: card.dropHere || card.wsId === overview.activeWs ? Theme.accent : Theme.glassBorder
                            border.width: card.dropHere ? 3 : card.wsId === overview.activeWs ? 2 : 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: overview.focusWorkspace(card.wsId) }
                            Text {
                                anchors.centerIn: parent
                                visible: card.wsWindows.length === 0
                                text: card.dropHere ? "Drop here" : "Empty workspace"
                                color: card.dropHere ? Theme.accent : Theme.subtext0
                                font.family: Theme.fontMain; font.pixelSize: 13
                            }
                            Repeater {
                                model: ScriptModel { values: card.wsWindows.map(c => c.address) }
                                delegate: Rectangle {
                                    id: win
                                    objectName: "overview-window-" + client.address
                                    required property var modelData
                                    readonly property var client: overview.clients.find(c => c.address === modelData) || ({address: modelData, class: "", title: "", workspace: {id: 0}, monitor: -1, at: [0,0], size: [0,0], floating: false})
                                    readonly property var mon: overview.monitorFor(client.monitor)
                                    readonly property real monW: mon ? mon.width / mon.scale : overview.width
                                    readonly property real monH: mon ? mon.height / mon.scale : overview.height
                                    readonly property bool selected: overview.selectedAddress === client.address
                                    readonly property bool matching: overview.matches(client)
                                    readonly property var toplevel: overview.toplevelFor(client)
                                    x: Math.max(0, (client.at[0] - (mon ? mon.x : 0)) / monW * tile.width)
                                    y: Math.max(0, (client.at[1] - (mon ? mon.y : 0)) / monH * tile.height)
                                    width: Math.max(0, Math.min(tile.width - x, Math.max(24, client.size[0] / monW * tile.width)))
                                    height: Math.max(0, Math.min(tile.height - y, Math.max(24, client.size[1] / monH * tile.height)))
                                    Behavior on x { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                                    Behavior on y { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                                    Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                                    Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                                    z: client.floating ? 2 : 1
                                    opacity: !matching ? 0.17 : stage.dragging && stage.dragKind === "window" && stage.payload && stage.payload.address === client.address ? 0.3 : 1
                                    Behavior on opacity { NumberAnimation { duration: 120 } }
                                    radius: 8; antialiasing: true; clip: true
                                    color: "transparent"
                                    border.color: selected || winHover.hovered ? Theme.accent : Theme.borderMuted
                                    border.width: selected ? 2 : 1
                                    ScreencopyView {
                                        id: thumb
                                        anchors { fill: parent; margins: 2 }
                                        captureSource: win.toplevel ? win.toplevel.wayland : null
                                        live: overview.visible && win.matching && !stage.dragging
                                    }
                                    Image {
                                        anchors.centerIn: parent
                                        width: Math.min(40, parent.width * 0.5); height: width
                                        sourceSize: Qt.size(48, 48)
                                        source: overview.iconFor(win.client)
                                        visible: !thumb.hasContent
                                    }
                                    Rectangle {
                                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                        height: Math.min(28, parent.height)
                                        color: Qt.rgba(0, 0, 0, 0.68)
                                        visible: win.selected || winHover.hovered
                                        RowLayout {
                                            anchors { fill: parent; leftMargin: 7; rightMargin: 7 }
                                            spacing: 6
                                            Image { source: overview.iconFor(win.client); Layout.preferredWidth: 15; Layout.preferredHeight: 15; sourceSize: Qt.size(20,20) }
                                            Text { text: win.client.title || win.client.class; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                                        }
                                    }
                                    HoverHandler { id: winHover; cursorShape: Qt.OpenHandCursor }
                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: win.matching && !overview.busy
                                        preventStealing: true
                                        onPressed: mouse => stage.begin("window", win.client, this, mouse)
                                        onPositionChanged: mouse => stage.update(this, mouse)
                                        onReleased: stage.finish()
                                        onCanceled: stage.cancel()
                                    }
                                }
                            }
                        }
                    }
            }
            Text {
                anchors.centerIn: parent
                visible: overview.workspaceIds.length === 0
                text: "No windows on regular workspaces\nUse + Workspace to add a drop target"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 15
            }
            Rectangle {
                visible: stage.dragging
                x: stage.dragPoint.x + 16; y: stage.dragPoint.y + 14
                width: 215; height: 66; z: 1000
                color: Theme.glassBg; border.color: Theme.accent; radius: 10
                RowLayout {
                    anchors { fill: parent; margins: 12 }
                    spacing: 10
                    Image { visible: stage.dragKind === "window"; source: stage.payload && stage.dragKind === "window" ? overview.iconFor(stage.payload) : ""; Layout.preferredWidth: 28; Layout.preferredHeight: 28 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: stage.dragKind === "window" && stage.payload ? stage.payload.class : "Workspace " + stage.payload; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: stage.dropWorkspace > 0 ? (stage.dragKind === "workspace" ? "Swap with " : "Move to ") + stage.dropWorkspace : "Choose a workspace"; color: Theme.accent; font.family: Theme.fontMain; font.pixelSize: 11 }
                    }
                }
            }
            Column {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 38 }
                spacing: 10
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: overview.busy ? "Moving…" : overview.message; color: Theme.accent; font.family: Theme.fontMain; font.pixelSize: 13 }
                Text { text: "Drag a window to move · Drag a header to swap · Shift + 1–0 moves selected · Ctrl+Z undoes · Esc closes"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 11 }
            }
            Component.onCompleted: forceActiveFocus()
        }
    }
}
