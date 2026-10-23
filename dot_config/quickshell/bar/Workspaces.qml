pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs
import qs.services

Row {
    id: workspaces
    spacing: 0
    property var peekClients: []
    property int requestedPeek: 0
    property int activePeek: 0
    property int displayedPeek: 0
    onActivePeekChanged: if (activePeek > 0) displayedPeek = activePeek
    property int hoveredWorkspaceId: 0
    property var pendingAnchor: null
    property bool refreshPending: false

    function hidePeek() {
        openPeek.stop(); closePeek.stop();
        requestedPeek = 0; activePeek = 0;
    }
    function beginPeek(id, item) {
        hoveredWorkspaceId = id;
        closePeek.stop();
        if (!occupied[String(id)]) { hidePeek(); return; }
        if (activePeek === id) return;
        activePeek = 0; requestedPeek = 0;
        pendingAnchor = item;
        openPeek.restart();
    }
    function leavePeek(id) {
        if (hoveredWorkspaceId !== id) return;
        hoveredWorkspaceId = 0;
        openPeek.stop();
        if (activePeek > 0) closePeek.restart();
        else requestedPeek = 0;
    }
    function fetchPreview() {
        if (clientFetch.running) refreshPending = true;
        else clientFetch.running = true;
    }
    Component.onCompleted: Hyprland.refreshToplevels()
    Timer {
        id: openPeek
        interval: 240
        onTriggered: {
            if (!workspaces.hoveredWorkspaceId || !workspaces.pendingAnchor) return;
            preview.anchor.item = workspaces.pendingAnchor;
            workspaces.requestedPeek = workspaces.hoveredWorkspaceId;
            workspaces.fetchPreview();
        }
    }
    Timer {
        id: closePeek
        interval: 180
        onTriggered: if (!peekHover.hovered && !workspaces.hoveredWorkspaceId) workspaces.hidePeek()
    }
    Timer {
        interval: 450
        repeat: true
        running: workspaces.activePeek > 0
        onTriggered: workspaces.fetchPreview()
    }
    Process {
        id: clientFetch
        command: ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    if (!Array.isArray(data)) throw new Error("Invalid workspace data");
                    workspaces.peekClients = data;
                    var id = workspaces.requestedPeek;
                    if (id > 0 && (workspaces.hoveredWorkspaceId === id || workspaces.activePeek === id || peekHover.hovered))
                        workspaces.activePeek = data.some(c => c.workspace === String(id)) ? id : 0;
                } catch (error) {
                    workspaces.activePeek = 0;
                    console.warn("Workspace preview:", error);
                }
            }
        }
        onExited: Qt.callLater(() => {
            if (workspaces.refreshPending && workspaces.requestedPeek > 0) {
                workspaces.refreshPending = false;
                workspaces.fetchPreview();
            }
        })
    }
    Process { id: focusWindow }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (workspaces.requestedPeek > 0 && /^(openwindow|closewindow|movewindow|activewindow|monitor)/.test(event.name))
                workspaces.fetchPreview();
        }
    }
    PopupWindow {
        id: preview
        anchor.item: workspaces
        anchor.rect.y: anchor.item ? anchor.item.height + 8 : 0
        implicitWidth: peek.implicitWidth
        implicitHeight: peek.implicitHeight
        color: "transparent"
        readonly property bool opened: workspaces.activePeek > 0
        property real reveal: opened ? 1 : 0
        Behavior on reveal { NumberAnimation { duration: preview.opened ? 140 : 100; easing.type: Easing.OutCubic } }
        visible: opened || reveal > 0.001
        WorkspacePeek {
            id: peek
            anchors.fill: parent
            opacity: preview.reveal
            workspaceId: String(workspaces.displayedPeek)
            clients: workspaces.peekClients
            HoverHandler {
                id: peekHover
                onHoveredChanged: {
                    if (hovered) closePeek.stop();
                    else closePeek.restart();
                }
            }
            onSelected: client => {
                workspaces.hidePeek();
                if (focusWindow.running) return;
                focusWindow.command = ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "focus-window", "--request", JSON.stringify({address: client.address, pid: client.pid})];
                focusWindow.running = true;
            }
        }
    }

    // Workspaces are matched by *name*, not id. On Hyprland 0.56.2 + quickshell
    // 0.3.1, workspaces that existed before quickshell (re)started are
    // registered with id -1 (probed 2026-09-23); the name is always right.
    // Hyprland.workspaces is an ObjectModel — it has `.values`, not
    // `.count`/`.get()`, which is why the old occupied-highlight never lit up.
    readonly property var occupied: {
        var names = {};
        Hyprland.toplevels.values.forEach(t => {
            if (t.workspace) names[t.workspace.name] = true;
        });
        return names;
    }
    readonly property string focusedName: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.name : ""

    // Persistent 1-5, plus 6-10 while occupied or focused — SUPER+1..0 binds
    // ten, and a workspace the bar can't show is one you can get lost on.
    function isShown(id) {
        return id <= 5 || occupied[String(id)] === true || focusedName === String(id);
    }

    // A fresh quickshell only learns about windows from open/close events, so
    // windows that already existed at (re)start never marked their workspace
    // occupied. Pull the current client list once up front.

    function goTo(target) {
        hidePeek();
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })");
    }

    // Ten fixed slots rather than a model that changes length: a changing JS
    // array model makes the Repeater rebuild every pill, so workspace 6+ used
    // to pop in at full size. Each slot now animates `reveal` 0 ↔ 1 and its
    // width, opacity and scale follow — the bar's left module widens with it.
    Repeater {
        model: 10

        delegate: Item {
            id: slot

            required property int index
            readonly property int wsId: index + 1
            readonly property int gap: index > 0 ? 6 : 0

            property real reveal: workspaces.isShown(wsId) ? 1 : 0
            Behavior on reveal { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

            width: (gap + wsRect.width) * reveal
            height: 28
            opacity: reveal
            visible: reveal > 0   // hidden slots also drop out of Tab focus
            clip: true

            Rectangle {
                id: wsRect

                readonly property int wsId: slot.wsId
                readonly property bool isFocused: workspaces.focusedName === String(wsId)
                readonly property bool isOccupied: workspaces.occupied[String(wsId)] === true

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: isFocused ? Math.max(38, wsLabel.implicitWidth + 18) : 16
                height: 28
                radius: Theme.widgetRadius
                antialiasing: true
                scale: 0.6 + 0.4 * slot.reveal

                activeFocusOnTab: true

                HoverHandler {
                    id: wsHover
                    onHoveredChanged: {
                        if (hovered) workspaces.beginPeek(wsRect.wsId, wsRect);
                        else workspaces.leavePeek(wsRect.wsId);
                    }
                }
                // Highlight when focused, hovered, or occupied
                color: {
                    if (isFocused) return Theme.bgSelection;
                    // Hover / keyboard focus: the bar's quiet glass lift (see BarItem)
                if (wsHover.hovered || wsRect.activeFocus) return Qt.rgba(1, 1, 1, 0.08);
                    if (isOccupied) return "transparent";
                    return "transparent";
                }
                border.color: isFocused || wsRect.activeFocus ? Theme.accent
                        : wsHover.hovered ? Qt.rgba(1, 1, 1, 0.10)
                        : isOccupied ? Theme.borderMuted : "transparent"
                border.width: 1

                Keys.onReturnPressed: workspaces.goTo(wsId)
                Keys.onSpacePressed: workspaces.goTo(wsId)

                // Smooth, no overshoot — the old OutBack spring stretched the pill
            // past its size and snapped back, which read as bouncy.
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.centerIn: parent
                    width: 5; height: 5; radius: 2.5
                    visible: !wsRect.isFocused
                    color: wsRect.isOccupied ? Theme.accent : Theme.borderMuted
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }
                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    visible: wsRect.isFocused
                    text: DesktopState.labels[String(wsRect.wsId)] || wsRect.wsId.toString()
                    color: (wsRect.isFocused || wsHover.hovered || wsRect.isOccupied) ? Theme.text : Theme.subtext0

                    font.family: Theme.fontMain
                    font.pixelSize: 12
                    font.weight: wsRect.isFocused ? Font.ExtraBold : Font.Bold
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: workspaces.goTo(wsRect.wsId)
                    // Same direction as SUPER+scroll in keybindings.lua. This used
                    // to exec `hyprctl dispatch workspace e-1` — hyprlang syntax,
                    // which the Lua config rejects ("')' expected near 'e'").
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y > 0) workspaces.goTo('"e-1"');
                        else if (wheel.angleDelta.y < 0) workspaces.goTo('"e+1"');
                    }
                }
            }
        }
    }
}
