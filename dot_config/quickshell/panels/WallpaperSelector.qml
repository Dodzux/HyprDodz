import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

PanelWindow {
    id: wallpaperWindow
    visible: false
    function choose(item) {
        Quickshell.execDetached(["systemd-run", "--user", "--scope", "--quiet", "--collect",
                                "--slice=app.slice", "--description=Wallpaper switch", "bash",
                                Quickshell.env("HOME") + "/.config/hypr/scripts/awww_transition.sh", item.path]);
        visible = false;
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-wallpaper-selector"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"


    property bool keyboardSelection: false
    property point lastPointerPosition: Qt.point(-1, -1)
    property bool repeatedNavigation: false
    property double lastNavigationStep: 0
    property int lastNavigationKey: 0
    Timer { id: repeatSettle; interval: 80; onTriggered: wallpaperWindow.repeatedNavigation = false }
    property var navigationKeys: ({})
    readonly property bool navigationHeld: Object.keys(navigationKeys).length > 0
    function pressNavigation(event) {
        repeatSettle.stop();
        var repeated = navigationKeys[event.key] || event.isAutoRepeat;
        if (repeated) repeatedNavigation = true;
        var next = Object.assign({}, navigationKeys); next[event.key] = true;
        navigationKeys = next; keyboardSelection = true; event.accepted = true;
        // Large thumbnail rows cannot follow terminal-speed key repeat. Pace
        // repeats without queuing stale moves that would run after release.
        var now = Date.now();
        if (repeated && lastNavigationKey === event.key && now - lastNavigationStep < 70) return false;
        lastNavigationStep = now;
        lastNavigationKey = event.key;
        return true;
    }
    function releaseNavigation(event) {
        if (event.isAutoRepeat || !navigationKeys[event.key]) return;
        var next = Object.assign({}, navigationKeys); delete next[event.key];
        navigationKeys = next;
        if (!navigationHeld) repeatSettle.restart();
        event.accepted = true;
    }

    property var wallpapers: []
    property var assets: ({})
    property bool loading: false
    property string loadingError: ""
    property real revealProgress: 0
    function refresh() {
        if (findProc.running) return;
        loading = true;
        loadingError = "";
        findProc.running = true;
    }
    function acceptUpdate(line) {
        try {
            var update = JSON.parse(line);
            if (update.type === "list") {
                var nextAssets = {};
                var entries = update.items.map(item => {
                    nextAssets[item.path] = item;
                    return {path: item.path, name: item.name};
                });
                assets = nextAssets;
                // Asset arrivals never rebuild the grid or reset keyboard selection.
                if (JSON.stringify(entries) !== JSON.stringify(wallpapers)) wallpapers = entries;
            } else if (update.type === "asset") {
                var next = Object.assign({}, assets);
                next[update.item.path] = update.item;
                assets = next;
            } else if (update.type === "done") loading = false;
            else if (update.type === "error") { loading = false; loadingError = update.message; }
        } catch (error) { console.warn("Wallpaper preview:", error); }
    }
    Timer { interval: 700; running: true; onTriggered: wallpaperWindow.refresh() }
    onVisibleChanged: {
        navigationKeys = ({});
        repeatSettle.stop();
        repeatedNavigation = false;
        if (visible) { keyboardSelection = false; reveal.restart(); searchInput.forceActiveFocus(); }
        else { reveal.stop(); revealProgress = 0; }
    }
    NumberAnimation { id: reveal; target: wallpaperWindow; property: "revealProgress"; from: 0; to: 1; duration: Theme.motionNormal; easing.type: Easing.OutCubic }
    property var filteredWallpapers: {
        var q = searchInput.text.toLowerCase().trim()
        return wallpapers.filter(function(item) {
            return !q || item.name.toLowerCase().includes(q);
        }).sort(function(a, b) {
            // Numbered variants belong under the wallpaper name (Rain World → R).
            var nameA = a.name.toLowerCase().replace(/^\d+[\s._-]+/, "");
            var nameB = b.name.toLowerCase().replace(/^\d+[\s._-]+/, "");
            return nameA.localeCompare(nameB)
                || a.name.toLowerCase().localeCompare(b.name.toLowerCase())
                || a.path.localeCompare(b.path);
        });
    }

    Process {
        id: findProc
        command: ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "wallpapers",
                  "--cache", Quickshell.env("HOME") + "/.cache/quickshell/wallpaper-palettes"]
        stdout: SplitParser { onRead: line => wallpaperWindow.acceptUpdate(line) }
        onExited: exitCode => {
            wallpaperWindow.loading = false;
            if (exitCode !== 0) wallpaperWindow.loadingError = "Could not load wallpaper previews";
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: wallpaperWindow.visible = false
    }

    Rectangle {
        id: panelCard
        Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
        width: 840
        height: wallpaperWindow.loading && wallpaperWindow.wallpapers.length === 0 ? 600 : Math.min(600, Math.max(160, 12 + headerBox.height + 12 + Math.ceil(wallpaperWindow.filteredWallpapers.length / 4) * gridList.cellHeight + 12))
        anchors.centerIn: parent

        color: Theme.glassBg
        radius: 14
        antialiasing: true
        border.color: Theme.glassBorder
        border.width: 1

        opacity: wallpaperWindow.revealProgress

        transform: Translate {
            y: (1 - wallpaperWindow.revealProgress) * 12
        }

        MouseArea {
            anchors.fill: parent
            onClicked: searchInput.forceActiveFocus()
        } // Block background click and keep focus

        // Viewport scrolling moves tiles under a stationary pointer. Only a
        // real pointer movement may hand selection back from the keyboard.
        HoverHandler {
            id: selectionPointer
            blocking: false
            function moved() {
                if (!hovered) return;
                var p = point.scenePosition;
                if (p.x === wallpaperWindow.lastPointerPosition.x && p.y === wallpaperWindow.lastPointerPosition.y) return;
                wallpaperWindow.lastPointerPosition = Qt.point(p.x, p.y);
                if (wallpaperWindow.navigationHeld) return;
                var view = gridList.mapFromItem(panelCard, point.position.x, point.position.y);
                if (view.x < 0 || view.y < 0 || view.x >= gridList.width || view.y >= gridList.height) return;
                wallpaperWindow.keyboardSelection = false;
                var content = gridList.contentItem.mapFromItem(panelCard, point.position.x, point.position.y);
                var index = gridList.tileAt(content.x, content.y);
                if (index >= 0) gridList.select(index);
            }
            onPointChanged: moved()
            onHoveredChanged: if (hovered) moved()
        }

        Rectangle {
            id: headerBox
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            height: 46
            radius: 8
            color: Theme.glassBg
            border.width: 0

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                spacing: 10

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Theme.text
                    selectByMouse: true
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.onAccent
                    font.family: Theme.fontMain
                    font.pixelSize: 14
                    focus: wallpaperWindow.visible

                    Text {
                        anchors.fill: parent
                        text: "Search wallpapers..."
                        color: Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 14
                        visible: parent.text.length === 0
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: wallpaperWindow.visible = false
                    Keys.onDownPressed: event => { if (wallpaperWindow.pressNavigation(event)) gridList.step(4); }
                    Keys.onUpPressed: event => { if (wallpaperWindow.pressNavigation(event)) gridList.step(-4); }
                    Keys.onRightPressed: event => { if (wallpaperWindow.pressNavigation(event)) gridList.step(1); }
                    Keys.onLeftPressed: event => { if (wallpaperWindow.pressNavigation(event)) gridList.step(-1); }
                    Keys.onReleased: event => wallpaperWindow.releaseNavigation(event)
                    onActiveFocusChanged: if (!activeFocus) { wallpaperWindow.navigationKeys = ({}); repeatSettle.restart(); }
                    Keys.onReturnPressed: {
                        if (wallpaperWindow.filteredWallpapers.length > 0) {
                            var entry = wallpaperWindow.filteredWallpapers[gridList.tileIndex]
                            if (entry) {
                                wallpaperWindow.choose(entry)
                                wallpaperWindow.visible = false
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: gridList
            anchors {
                top: headerBox.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 12
                bottomMargin: 12
                topMargin: 12
            }

            readonly property real cellWidth: Math.floor((width - 8) / 4)
            readonly property real cellHeight: Math.floor((cellWidth / 16) * 9) + 61

            readonly property var rows: {
                var result = [], entries = wallpaperWindow.filteredWallpapers;
                for (var i = 0; i < entries.length; i += 4)
                    result.push({key: entries[i].path, items: entries.slice(i, i + 4)});
                return result;
            }
            property int tileIndex: wallpaperWindow.filteredWallpapers.length ? 0 : -1
            property bool columnWrap: false
            function select(index, wrap) {
                if (index < 0 || index >= wallpaperWindow.filteredWallpapers.length) return;
                columnWrap = wrap === true;
                tileIndex = index;
            }
            function step(offset) {
                var next = tileIndex + offset;
                select(next, Math.abs(offset) === 1 && Math.floor(next / 4) !== Math.floor(tileIndex / 4));
            }
            function tileAt(x, y) {
                var row = indexAt(x, y), column = Math.floor(x / cellWidth);
                var index = row * 4 + column;
                return row >= 0 && column >= 0 && column < 4 && index < wallpaperWindow.filteredWallpapers.length ? index : -1;
            }
            model: ScriptModel {
                values: gridList.rows
                objectProp: "key"
                onValuesChanged: Qt.callLater(() => { gridList.tileIndex = wallpaperWindow.filteredWallpapers.length ? 0 : -1; })
            }
            add: Transition { enabled: !wallpaperWindow.loading; NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.motionNormal } }
            displaced: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            currentIndex: tileIndex < 0 ? -1 : Math.floor(tileIndex / 4)
            reuseItems: true
            cacheBuffer: cellHeight
            clip: true
            // One native ListView highlight also drives viewport scrolling,
            // exactly as in AppLauncher; there is no independent visual tracker.
            highlightMoveDuration: wallpaperWindow.repeatedNavigation ? 55 : Theme.launcherSelectionDuration
            highlightMoveVelocity: -1
            highlight: Item {
                width: gridList.width
                height: gridList.cellHeight
                Rectangle {
                    id: selectionBackground
                    x: (Math.max(0, gridList.tileIndex) % 4) * gridList.cellWidth + 6
                    y: 6
                    width: gridList.cellWidth - 12
                    height: gridList.cellHeight - 12
                    radius: 10
                    antialiasing: true
                    color: Theme.launcherSelectionBg
                    border.color: Theme.launcherSelectionBorder
                    border.width: 1
                    // A row wrap starts at its destination column instead of
                    // sweeping backwards over three unrelated thumbnails.
                    Behavior on x { enabled: !gridList.columnWrap; SmoothedAnimation { duration: wallpaperWindow.repeatedNavigation ? 55 : Theme.launcherSelectionDuration; velocity: -1 } }
                    Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                visible: gridList.contentHeight > gridList.height
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    // Wallpaper accent (set live by sync_border.py); brighter
                    // while it is being dragged. Same as the app launcher.
                    color: parent.pressed ? Qt.lighter(Theme.accent, 1.3) : Theme.accent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            delegate: Item {
                id: wallpaperRow
                required property int index
                required property var modelData
                width: gridList.width
                height: gridList.cellHeight
                ListView.onReused: wallpaperRow.opacity = 1
                Repeater {
                    model: wallpaperRow.modelData.items
                    delegate: Item {
                        id: wallpaperTile
                        width: gridList.cellWidth
                        height: gridList.cellHeight

                        required property var modelData
                        required property int index
                        readonly property int entryIndex: wallpaperRow.index * 4 + index
                        x: index * gridList.cellWidth
                        readonly property var asset: wallpaperWindow.assets[modelData.path] || ({})
                        readonly property bool highlighted: gridList.tileIndex === entryIndex

                        Rectangle {
                            anchors { fill: parent; margins: 6 }
                            radius: 10
                            color: !wallpaperWindow.keyboardSelection && itemHover.hovered && gridList.tileIndex !== wallpaperTile.entryIndex ? Theme.launcherHoverBg : "transparent"
                            border.color: "transparent"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                            Behavior on border.color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { gridList.select(wallpaperTile.entryIndex); wallpaperWindow.choose(wallpaperTile.modelData); }
                            }
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.margins: 6
                                    radius: 6
                                    color: Theme.hoverBg
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: wallpaperTile.asset.thumbnail || ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        sourceSize: Qt.size(384, 216)
                                        opacity: status === Image.Ready ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
                                    }
                                }

                                Row {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 4
                                    Repeater {
                                        model: wallpaperTile.asset.swatches || []
                                        Rectangle {
                                            required property var modelData
                                            required property int index
                                            width: index === 0 ? 22 : 14
                                            height: 8
                                            radius: 4
                                            color: modelData
                                            border.width: 1
                                            border.color: Theme.glassBorder
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.name
                                    color: wallpaperTile.highlighted ? Theme.accent : Theme.text
                                    Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                                    font.family: Theme.fontMain
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    Layout.margins: 6
                                    Layout.topMargin: 0
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            HoverHandler {
                                id: itemHover
                                onHoveredChanged: if (hovered && !wallpaperWindow.keyboardSelection) gridList.select(wallpaperTile.entryIndex)
                            }

                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: wallpaperWindow.loadingError || (wallpaperWindow.loading ? "Loading wallpapers…" : searchInput.text.length > 0 ? "No wallpapers match your search" : "No wallpapers found")
                color: Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 13
                visible: gridList.count === 0
            }
        }


    }

    function toggle(scr) {
        if (wallpaperWindow.visible) {
            wallpaperWindow.visible = false;
            return;
        }
        if (scr) {
            wallpaperWindow.screen = scr;
        }
        searchInput.text = "";
        refresh();
        wallpaperWindow.visible = true;
    }
}
