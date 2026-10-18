import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs
import qs.services

PanelWindow {
    id: bar
    required property var modelData

    screen: modelData
    implicitHeight: 44
    exclusiveZone: 48 // Account for top margin and height
    color: "transparent"

    property bool isKeyboardFocused: false
    WlrLayershell.keyboardFocus: isKeyboardFocused ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Connections {
        target: root
        function onToggleBarFocus() {
            if (Hyprland.focusedMonitor && bar.screen && Hyprland.focusedMonitor.name === bar.screen.name) {
                bar.isKeyboardFocused = !bar.isKeyboardFocused;
                if (bar.isKeyboardFocused) {
                    barContentItem.forceActiveFocus();
                }
            }
        }
    }

    margins {
        top: 7
        left: 11
        right: 11
    }

    anchors {
        top: true
        left: true
        right: true
    }

    function handleControlDrop(key, globalX, globalY) {
        if (!controlsRow.acceptControlDrop(key, globalX, globalY))
            statusRow.acceptControlDrop(key, globalX, globalY);
    }
    readonly property var widgetRegistry: ({stats: statsComponent, network: networkComponent,
        bluetooth: bluetoothComponent, audio: audioComponent, mic: micComponent,
        brightness: brightnessComponent, battery: batteryComponent, language: languageComponent,
        notifications: notificationsComponent, shortcuts: shortcutsComponent, tray: trayComponent,
        settings: settingsComponent, power: powerComponent})
    Component { id: statsComponent; SysMonitor {} }
    Component { id: networkComponent; NetworkWidget { parentWindow: bar; compact: true } }
    Component { id: bluetoothComponent; BluetoothWidget { parentWindow: bar } }
    Component { id: audioComponent; AudioWidget {} }
    Component { id: micComponent; MicWidget {} }
    Component { id: brightnessComponent; BrightnessWidget {} }
    Component { id: batteryComponent; BatteryWidget {} }
    Component { id: languageComponent; KeyboardLayout {} }
    Component { id: notificationsComponent; NotificationButton {} }
    Component { id: shortcutsComponent; CheatsheetButton {} }
    Component { id: trayComponent; SystemTray { parentWindow: bar } }
    Component { id: powerComponent; PowerButton { parentWindow: bar } }
    Component {
        id: settingsComponent
        BarItem {
            width: 28
            Accessible.name: "Desktop controls. Right click for Health"
            Keys.onReturnPressed: root.openDesktopSettings("layout")
            Keys.onSpacePressed: root.openDesktopSettings("layout")
            Text { anchors.centerIn: parent; text: "󰒓"; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: Theme.iconSize }
            TapHandler { acceptedButtons: Qt.LeftButton; onTapped: root.openDesktopSettings("layout") }
            TapHandler { acceptedButtons: Qt.RightButton; onTapped: root.openDesktopSettings("health") }
        }
    }

    Item {
        id: barContentItem
        objectName: "bar-content"
        anchors.fill: parent
        anchors.margins: 3
        focus: bar.isKeyboardFocused

        Keys.onEscapePressed: {
            if (DesktopState.editing) DesktopState.finishEdit(false);
            bar.isKeyboardFocused = false;
        }

        // Keep the clock centered even as either wing expands.
        readonly property real wingLimit: Math.max(0, (width - clockPill.width) / 2 - 18)


        Rectangle {
            id: navigationPill
            objectName: "bar-navigation"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 38
            width: navigationRow.implicitWidth + 24
            color: Theme.glassBg
            border.width: DesktopState.editing ? 1 : 0
            border.color: Theme.accent
            radius: 19
            antialiasing: true
            Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            Row {
                id: navigationRow
                height: 28
                anchors.centerIn: parent
                spacing: 8

                Workspaces { id: workspaceList }
                Rectangle { width: 1; height: 14; anchors.verticalCenter: parent.verticalCenter; color: Theme.borderMuted; visible: appStrip.width > 0 }
                Taskbar {
                    id: appStrip
                    objectName: "bar-apps"
                    width: Math.min(implicitWidth, Math.max(34, barContentItem.wingLimit
                        - workspaceList.width - caffeine.width - submap.width
                        - (compactMedia.hasMedia ? 160 : 0) - 84))
                    visible: width > 0
                    interactive: contentWidth > width
                    clip: contentWidth > width
                    boundsBehavior: Flickable.StopAtBounds
                }
                SubmapIndicator { id: submap }
                Rectangle { width: 1; height: 14; anchors.verticalCenter: parent.verticalCenter; color: Theme.borderMuted; visible: compactMedia.width > 0 }
                MediaWidget {
                    id: compactMedia
                    objectName: "bar-media"
                    maximumWidth: Math.min(190, Math.max(0, barContentItem.wingLimit
                        - workspaceList.width - appStrip.width - caffeine.width - submap.width - 84))
                }
                IdleInhibitorWidget { id: caffeine }
            }
        }

        Rectangle {
            id: clockPill
            objectName: "bar-clock"
            anchors.centerIn: parent
            height: 38
            width: DesktopState.editing ? editActions.implicitWidth + 24 : centeredClock.width + 24
            color: Theme.glassBg
            border.width: DesktopState.editing ? 1 : 0
            border.color: Theme.accent
            radius: 19
            antialiasing: true
            Row {
                id: editActions
                anchors.centerIn: parent
                spacing: 6
                visible: DesktopState.editing
                Repeater {
                    model: ["Save", "Cancel", "Reset"]
                    BarItem {
                        required property string modelData
                        width: editLabel.implicitWidth + 14
                        Text { id: editLabel; anchors.centerIn: parent; text: parent.modelData; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 11 }
                        function act() {
                            if (modelData === "Reset") DesktopState.resetLayout();
                            else DesktopState.finishEdit(modelData === "Save");
                        }
                        Keys.onReturnPressed: act()
                        Keys.onSpacePressed: act()
                        TapHandler { onTapped: parent.act() }
                    }
                }
            }
            Clock {
                id: centeredClock
                parentWindow: bar
                visible: !DesktopState.editing
                anchors.centerIn: parent
            }
        }

        // On unusually narrow/crowded displays, scroll the controls instead
        // of allowing them to cover the fixed clock.
        Flickable {
            id: rightWing
            objectName: "bar-right-wing"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 38
            width: Math.min(contentWidth, barContentItem.wingLimit)
            contentWidth: rightGroups.implicitWidth
            contentHeight: height
            contentX: Math.max(0, contentWidth - width)
            clip: contentWidth > width
            interactive: contentWidth > width && !DesktopState.editing
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            HoverHandler { id: rightWingHover; blocking: false; enabled: !DesktopState.editing }

            Row {
                id: rightGroups
                spacing: 8
                Rectangle {
                    id: controlsPill
                    objectName: "bar-controls"
                    height: 38
                    width: Math.max(controlsRow.targetWidth, controlsRow.implicitWidth) + 20
                    color: Theme.glassBg
            border.width: DesktopState.editing ? 1 : 0
            border.color: Theme.accent
                    radius: 19
                    antialiasing: true
                    clip: !DesktopState.editing
                    Behavior on width {
                        enabled: !DesktopState.editing
                        NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
                    }
                    MovableGroup {
                        id: controlsRow
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        groupKey: "controls"
                        keys: DesktopState.controls
                        registry: bar.widgetRegistry
                        hoverSession: rightWingHover.hovered
                        onDropRequested: (key, globalX, globalY) => bar.handleControlDrop(key, globalX, globalY)
                    }
                }
                Rectangle {
                    id: statusPill
                    objectName: "bar-status"
                    height: 38
                    width: Math.max(statusRow.targetWidth, statusRow.implicitWidth) + 20
                    color: Theme.glassBg
            border.width: DesktopState.editing ? 1 : 0
            border.color: Theme.accent
                    radius: 19
                    antialiasing: true
                    clip: !DesktopState.editing
                    Behavior on width {
                        enabled: !DesktopState.editing
                        NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
                    }
                    MovableGroup {
                        id: statusRow
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        groupKey: "status"
                        keys: DesktopState.status
                        registry: bar.widgetRegistry
                        hoverSession: rightWingHover.hovered
                        onDropRequested: (key, globalX, globalY) => bar.handleControlDrop(key, globalX, globalY)
                    }
                }
            }
        }
    }
}
