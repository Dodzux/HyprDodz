import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import "../DesktopActions.js" as Actions

// AppLauncher — replaces rofi -show drun
// Triggered by: SUPER+A (global shortcut)
// Uses Quickshell's built-in DesktopEntries to read all .desktop files

PanelWindow {
    id: launcherWindow
    visible: false
    property alias queryText: searchInput.text
    property var shortcutHints: ({})
    readonly property bool actionMode: searchInput.text.trim().startsWith(">")
    function showLauncher() {
        searchInput.text = "";
        visible = true;
        hintsProc.running = true;
    }
    Process {
        id: hintsProc
        command: ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "shortcuts"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { launcherWindow.shortcutHints = JSON.parse(this.text); }
                catch (error) { console.warn("Shortcut hints:", error); }
            }
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Full screen so clicking outside dismisses the panel
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"

    // ▓▒░ GLOBAL SHORTCUT — SUPER+A
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-launcher"
        description: "Toggle application launcher"
        onPressed: {
            if (launcherWindow.visible) {
                launcherWindow.visible = false;
                return;
            }
            var scr = root.getFocusedScreen();
            if (scr) {
                launcherWindow.screen = scr;
            }
            launcherWindow.showLauncher();
        }
    }

    // ▓▒░ LAUNCH LOGIC — strips desktop entry field codes (like %U), then starts
    // the app in its own transient systemd scope.
    //
    // The scope is not cosmetic. Quickshell.execDetached detaches the *process*
    // but not the *cgroup*: a bare execDetached child reparents to init and stays
    // inside quickshell.service, which is KillMode=control-group with
    // Restart=on-failure. So if quickshell ever crashed or was restarted, systemd
    // tore down its control group and every app ever launched from here -- editor,
    // browser, everything -- died with it. The old comment on this function
    // claimed detaching already prevented that. It did not.
    //
    // systemd-run makes each app a sibling of quickshell.service under app.slice
    // instead of a child, which is also what `man 7 systemd.special` prescribes for
    // interactively launched applications. Each app then gets its own cgroup, so it
    // can be inspected and stopped on its own:  systemctl --user list-units --type=scope
    function launchApp(app) {
        if (app.desktopAction) {
            if (app.id === "action:brightness")
                root.brightnessController.setBrightness(parseInt(app.command[app.command.length - 1]));
            else Quickshell.execDetached(app.command);
            launcherWindow.visible = false;
            return;
        }
        var cmdList = [];
        if (app.command) {
            cmdList = app.command.filter(function(arg) {
                return !arg.match(/^%[fFuUdDnNicu]$/);
            });
        }
        if (cmdList.length === 0) return;

        if (app.runInTerminal) {
            cmdList = ["kitty", "-e"].concat(cmdList);
        }
        Quickshell.execDetached([
            "systemd-run", "--user", "--scope", "--quiet", "--collect",
            "--slice=app.slice", "--description=" + (app.name || cmdList[0])
        ].concat(cmdList));
        launcherWindow.visible = false;
    }

    // Close on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: launcherWindow.visible = false
    }

    // ▓▒░ FILTERED APP LIST
    property var filteredApps: {
        var q = searchInput.text.toLowerCase().trim()
        var all = DesktopEntries.applications.values
        if (actionMode) return Actions.rows(q);
        if (!q) return all
        return all.filter(function(app) {
            return app.name.toLowerCase().includes(q)
                || (app.genericName && app.genericName.toLowerCase().includes(q))
                || (app.comment && app.comment.toLowerCase().includes(q))
                || (app.id && app.id.toLowerCase().includes(q))
                || (app.keywords && app.keywords.join(" ").toLowerCase().includes(q))
        })
    }

    // ▓▒░ CENTERED PANEL CARD
    Rectangle {
        id: launcherPanel
        Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
        width: 600
        height: Math.min(380, Math.max(160, headerBox.height + 20 + appList.contentHeight + 20))
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60

        color: Theme.glassBg
        radius: 14
        antialiasing: true
        border.color: Theme.glassBorder
        border.width: 1

        // Slide-down open animation
        opacity: launcherWindow.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        transform: Translate {
            y: launcherWindow.visible ? 0 : -16
            Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }

        // Block background click propagation
        MouseArea { anchors.fill: parent; onClicked: searchInput.forceActiveFocus() }

        // ── Search Box ──
        Rectangle {
            id: headerBox
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            height: 46
            radius: 8
            antialiasing: true
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
                    selectedTextColor: (0.299 * Theme.accent.r + 0.587 * Theme.accent.g + 0.114 * Theme.accent.b) > 0.5
                        ? Theme.base : Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 14
                    focus: launcherWindow.visible

                    // Qt doesn't expose placeholder natively in TextInput,
                    // so we layer a Text behind it
                    Text {
                        anchors.fill: parent
                        text: "Search apps, or > for quick actions"
                        color: Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 14
                        visible: parent.text.length === 0
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: launcherWindow.visible = false
                    Keys.onDownPressed:   appList.incrementCurrentIndex()
                    Keys.onUpPressed:     appList.decrementCurrentIndex()
                    Keys.onReturnPressed: {
                        if (launcherWindow.filteredApps.length > 0) {
                            var entry = launcherWindow.filteredApps[appList.currentIndex]
                            if (entry) {
                                launcherWindow.launchApp(entry);
                            }
                        }
                    }
                }

                // Result count badge
                Text {
                    text: launcherWindow.filteredApps.length + (launcherWindow.actionMode ? " actions" : " apps")
                    color: Theme.subtext0
                    font.family: Theme.fontMain
                    font.pixelSize: 11
                    visible: searchInput.text.length > 0
                }
            }
        }

        // ── App List ──
        ListView {
            id: appList
            anchors {
                top: headerBox.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
                topMargin: 6
            }

            model: ScriptModel {
                values: launcherWindow.filteredApps
                onValuesChanged: Qt.callLater(() => { appList.currentIndex = values.length ? 0 : -1; })
            }
            add: Transition {
                NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.motionNormal }
            }
            remove: Transition { NumberAnimation { properties: "opacity"; to: 0; duration: Theme.motionExit } }
            displaced: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }

            onModelChanged: Qt.callLater(function() {
                appList.currentIndex = appList.count > 0 ? 0 : -1;
                appList.positionViewAtBeginning();
            })
            currentIndex: 0
            clip: true
            highlightMoveDuration: Theme.launcherSelectionDuration
            highlightMoveVelocity: -1
            highlight: Rectangle {
                width: appList.width - 12
                radius: 10
                antialiasing: true
                color: Theme.launcherSelectionBg
                border.color: Theme.launcherSelectionBorder
                border.width: 1
                Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                visible: appList.contentHeight > appList.height
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    antialiasing: true
                    // Wallpaper accent (set live by sync_border.py); brighter
                    // while it is being dragged.
                    color: parent.pressed ? Qt.lighter(Theme.accent, 1.3) : Theme.accent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                background: Item {}
            }

            delegate: Rectangle {
                id: appRow
                width: appList.width - 12
                height: 50
                radius: 10
                antialiasing: true
                required property var modelData
                required property int index
                readonly property bool highlighted: appList.currentIndex === index || rowHover.hovered

                color: rowHover.hovered && appList.currentIndex !== index
                    ? Theme.launcherHoverBg : "transparent"
                border.color: "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 12

                    // App icon — uses Qt's built-in XDG icon theme provider
                    Image {
                        width: 28; height: 28
                        source: appRow.modelData.icon
                            ? (appRow.modelData.icon.startsWith("/")
                               ? appRow.modelData.icon
                               : "image://icon/" + appRow.modelData.icon)
                            : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        sourceSize: Qt.size(28, 28)

                        // Fallback glyph when icon fails to load
                        Text {
                            anchors.centerIn: parent
                            text: "󰣆"
                            color: appRow.highlighted ? Theme.accent : Theme.subtext0
                            Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                            font.family: Theme.fontMain
                            font.pixelSize: 20
                            visible: parent.status !== Image.Ready
                        }
                    }

                    // Name + description
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: appRow.modelData.name
                            color: appRow.highlighted ? Theme.accent : Theme.text
                            Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                            font.family: Theme.fontMain
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: appRow.modelData.comment || appRow.modelData.genericName || ""
                            color: appRow.highlighted ? Theme.accent : Theme.subtext0
                            Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                            font.family: Theme.fontMain
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: text.length > 0
                            renderType: Text.NativeRendering
                        }
                    }

                    Rectangle {
                        readonly property string shortcut: launcherWindow.shortcutHints[appRow.modelData.id] || ""
                        visible: shortcut.length > 0
                        implicitWidth: hintText.implicitWidth + 14
                        implicitHeight: 24
                        radius: 6
                        color: appRow.highlighted ? Theme.launcherSelectionBg : Theme.bgSelection
                        border.width: 1
                        border.color: appRow.highlighted ? Theme.launcherSelectionBorder : Theme.glassBorder
                        Text {
                            id: hintText
                            anchors.centerIn: parent
                            text: parent.shortcut
                            font.family: Theme.fontMain
                            font.pixelSize: 10
                            color: appRow.highlighted ? Theme.accent : Theme.subtext0
                        }
                    }

                    // Terminal indicator
                    Text {
                        text: ""
                        color: appRow.highlighted ? Theme.accent : Theme.subtext0
                        Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                        font.family: Theme.fontMain
                        font.pixelSize: 12
                        visible: appRow.modelData.runInTerminal
                    }
                }

                HoverHandler {
                    id: rowHover
                    onHoveredChanged: {
                        if (hovered) appList.currentIndex = appRow.index;
                    }
                }

                TapHandler {
                    onTapped: {
                        launcherWindow.launchApp(appRow.modelData);
                    }
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: "No apps found for \"" + searchInput.text + "\""
                color: Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 13
                visible: appList.count === 0
            }
        }
    }
}
