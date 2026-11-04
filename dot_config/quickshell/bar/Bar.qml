import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData
    readonly property string edge: BarState.edge
    readonly property bool vertical: BarState.vertical
    readonly property bool singleSideRail: true
    readonly property real screenX: edge === "right" ? screen.width - width : 0
    readonly property real screenY: edge === "bottom" ? screen.height - height : 0
    implicitWidth: vertical ? 76 : 1920
    implicitHeight: vertical ? 1200 : 58
    exclusiveZone: vertical ? 76 : 55
    color: "transparent"
    anchors {
        top: edge === "top" || vertical
        bottom: edge === "bottom" || vertical
        left: edge === "left" || !vertical
        right: edge === "right" || !vertical
    }
    property bool isKeyboardFocused: false
    property bool workspaceEditing: false
    WlrLayershell.keyboardFocus: workspaceEditing ? WlrKeyboardFocus.Exclusive : isKeyboardFocused ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    // Only the islands receive input; gaps remain available to desktop windows.
    mask: Region {
        Region { item: navigationPill }
        Region { item: clockPill }
        Region { item: controlsPill }
        Region { item: statusPill }
    }
    Connections {
        target: root
        function onDismissBarPopups() {
            workspaceList.endName(false); workspaceList.hidePeek();
            controlsRow.closePopups(); statusRow.closePopups();
            compactMedia.closePopup();
            bar.isKeyboardFocused = false;
        }
        function onToggleBarFocus() {
            if (Hyprland.focusedMonitor && bar.screen && Hyprland.focusedMonitor.name === bar.screen.name) {
                if (bar.workspaceEditing) { workspaceList.endName(false); return; }
                bar.isKeyboardFocused = !bar.isKeyboardFocused;
                if (bar.isKeyboardFocused) barContentItem.forceActiveFocus();
            }
        }
    }
    readonly property var widgetRegistry: ({stats: statsComponent, network: networkComponent,
        bluetooth: bluetoothComponent, audio: audioComponent, mic: micComponent,
        brightness: brightnessComponent, battery: batteryComponent, language: languageComponent,
        notifications: notificationsComponent, shortcuts: shortcutsComponent, tray: trayComponent,
        power: powerComponent})
    Component { id: statsComponent; SysMonitor { verticalBar: bar.vertical } }
    Component { id: networkComponent; NetworkWidget { parentWindow: bar; compact: true; verticalBar: bar.vertical } }
    Component { id: bluetoothComponent; BluetoothWidget { parentWindow: bar; verticalBar: bar.vertical } }
    Component { id: audioComponent; AudioWidget { verticalBar: bar.vertical } }
    Component { id: micComponent; MicWidget { verticalBar: bar.vertical } }
    Component { id: brightnessComponent; BrightnessWidget { verticalBar: bar.vertical } }
    Component { id: batteryComponent; BatteryWidget { verticalBar: bar.vertical } }
    Component { id: languageComponent; KeyboardLayout { verticalBar: bar.vertical } }
    Component {
        id: notificationsComponent
        NotificationButton {
            id: notificationWidget
            verticalBar: bar.vertical
            Component.onCompleted: BarState.registerNotificationWidget(bar.screen, bar, notificationWidget)
            Component.onDestruction: BarState.unregisterNotificationWidget(bar.screen, notificationWidget)
        }
    }
    Component { id: shortcutsComponent; CheatsheetButton { verticalBar: bar.vertical } }
    Component { id: trayComponent; SystemTray { parentWindow: bar; vertical: bar.vertical } }
    Component { id: powerComponent; PowerButton { parentWindow: bar; verticalBar: bar.vertical } }
    Item {
        id: barContentItem
        objectName: "bar-content"
        anchors.fill: parent
        opacity: BarState.moving ? 0 : 1
        enabled: !BarState.moving
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        focus: bar.isKeyboardFocused
        Keys.onEscapePressed: bar.isKeyboardFocused = false
        TapHandler {
            acceptedButtons: Qt.AllButtons
            onTapped: point => {
                if (!bar.workspaceEditing || !workspaceList.nameEditor) return;
                var pill = workspaceList.nameEditor.parent;
                var p = pill.mapFromItem(barContentItem, point.position.x, point.position.y);
                if (p.x < 0 || p.y < 0 || p.x > pill.width || p.y > pill.height) workspaceList.endName(false);
            }
        }
        readonly property real sideNavigationRoom: Math.max(80, height - clockPill.height - rightWing.height - 40)
        readonly property real sideStackHeight: clockPill.height + navigationPill.height + rightWing.height + 20
        readonly property real sideStart: Math.max(10, (height - sideStackHeight) / 2)
        Rectangle {
            visible: bar.vertical && bar.singleSideRail
            x: 8; y: 8
            width: 60; height: parent.height - 16
            radius: 25; color: Theme.glassBg; antialiasing: true
        }
        readonly property real wingLimit: Math.max(0, (width - clockPill.width) / 2 - 32)
        Rectangle {
            id: clockPill
            objectName: "bar-clock"
            x: bar.vertical ? 8 : (parent.width - width) / 2
            y: 10
            height: bar.vertical ? 40 : 38
            width: bar.vertical ? 60 : centeredClock.width + 24
            color: bar.vertical && bar.singleSideRail ? "transparent" : Theme.glassBg; radius: 19; antialiasing: true
            Clock { id: centeredClock; parentWindow: bar; verticalBar: bar.vertical; anchors.centerIn: parent }
        }
        Rectangle {
            id: navigationPill
            objectName: "bar-navigation"
            x: bar.vertical ? 8 : 14
            y: bar.vertical ? clockPill.y + clockPill.height + 4 : 10
            height: bar.vertical ? Math.max(0, Math.min(navigationRow.implicitHeight + 8, Math.max(0, rightWing.y - y - 12))) : 38
            width: bar.vertical ? 60 : navigationRow.implicitWidth + 24
            color: bar.vertical && bar.singleSideRail ? "transparent" : Theme.glassBg; radius: 19; antialiasing: true
            Behavior on height { enabled: bar.vertical && !BarState.moving; NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            Behavior on width { enabled: !compactMedia.layoutAnimating && !BarState.moving; NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            Flickable {
                anchors.centerIn: parent
                width: bar.vertical ? parent.width : navigationRow.implicitWidth
                height: bar.vertical ? Math.max(0, parent.height - 8) : 28
                contentWidth: width
                contentHeight: navigationRow.implicitHeight
                clip: bar.vertical
                interactive: bar.vertical && contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                Grid {
                    id: navigationRow
                    x: (parent.width - width) / 2
                    columns: bar.vertical ? 1 : 8
                    horizontalItemAlignment: Grid.AlignHCenter
                    verticalItemAlignment: Grid.AlignVCenter
                    spacing: bar.vertical ? 6 : 8
                    Workspaces { id: workspaceList; parentWindow: bar; vertical: bar.vertical }
                    Rectangle { width: bar.vertical ? 24 : 1; height: bar.vertical ? 1 : 14; color: Theme.borderMuted; visible: appStrip.count > 0 }
                    Taskbar {
                        id: appStrip; objectName: "bar-apps"; vertical: bar.vertical
                        width: bar.vertical ? 28 : Math.min(implicitWidth, Math.max(34, barContentItem.wingLimit
                            - workspaceList.width - caffeine.width - submap.width - (compactMedia.hasMedia ? 160 : 0) - 84))
                        height: bar.vertical ? Math.min(implicitHeight, 170) : 28
                        visible: count > 0
                        interactive: bar.vertical ? contentHeight > height : contentWidth > width
                        clip: interactive
                        boundsBehavior: Flickable.StopAtBounds
                    }
                    SubmapIndicator { id: submap; verticalBar: bar.vertical }
                    Rectangle { width: bar.vertical ? 24 : 1; height: bar.vertical ? 1 : 14; color: Theme.borderMuted; visible: compactMedia.width > 0 }
                    MediaWidget {
                        id: compactMedia; objectName: "bar-media"; verticalBar: bar.vertical
                        maximumWidth: bar.vertical ? 44 : Math.min(190, Math.max(0, barContentItem.wingLimit
                            - workspaceList.width - appStrip.width - caffeine.width - submap.width - 84))
                    }
                    IdleInhibitorWidget { id: caffeine; verticalBar: bar.vertical }
                }
            }
        }
        NothingWordmark {
            readonly property real gapTop: navigationPill.y + navigationPill.height
            readonly property real gapBottom: rightWing.y
            visible: bar.vertical && gapBottom - gapTop >= height + 24
            x: (parent.width - width) / 2
            y: (gapTop + gapBottom - height) / 2
        }
        Flickable {
            id: rightWing
            objectName: "bar-right-wing"
            x: bar.vertical ? 8 : parent.width - width - 14
            y: bar.vertical ? parent.height - height - 10 : 10
            height: bar.vertical ? Math.min(contentHeight, Math.max(120, parent.height - 420)) : 38
            width: bar.vertical ? 60 : Math.min(contentWidth, barContentItem.wingLimit)
            contentWidth: rightGroups.implicitWidth
            contentHeight: rightGroups.implicitHeight
            contentX: bar.vertical ? 0 : Math.max(0, contentWidth - width)
            clip: contentWidth > width || contentHeight > height
            interactive: clip
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: bar.vertical ? Flickable.VerticalFlick : Flickable.HorizontalFlick
            HoverHandler { id: rightWingHover; blocking: false }
            Grid {
                id: rightGroups
                columns: bar.vertical ? 1 : 2
                spacing: 8
                Rectangle {
                    id: controlsPill; objectName: "bar-controls"
                    height: bar.vertical ? controlsRow.implicitHeight + 14 : 38
                    width: bar.vertical ? 60 : controlsRow.implicitWidth + 20
                    color: bar.vertical && bar.singleSideRail ? "transparent" : Theme.glassBg; radius: 19; antialiasing: true; clip: true
                    MovableGroup {
                        id: controlsRow; anchors.centerIn: parent; vertical: bar.vertical
                        keys: DesktopState.controls; registry: bar.widgetRegistry
                        hoverSession: !bar.vertical && rightWingHover.hovered
                    }
                }
                Rectangle {
                    id: statusPill; objectName: "bar-status"
                    height: bar.vertical ? statusRow.implicitHeight + 14 : 38
                    width: bar.vertical ? 60 : statusRow.implicitWidth + 20
                    color: bar.vertical && bar.singleSideRail ? "transparent" : Theme.glassBg; radius: 19; antialiasing: true; clip: true
                    MovableGroup {
                        id: statusRow; anchors.centerIn: parent; vertical: bar.vertical
                        keys: DesktopState.status; registry: bar.widgetRegistry
                        hoverSession: !bar.vertical && rightWingHover.hovered
                    }
                }
            }
        }
    }
}
