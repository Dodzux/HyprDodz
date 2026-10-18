import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

BarItem {
    id: idleInhibitorWidget

    width: contentRow.implicitWidth + 16
    
    HoverHandler { id: hover }
    Accessible.name: "Keep awake " + (DesktopState.caffeine ? "on" : "off") + ", Do Not Disturb " + (DndService.isEnabled ? "on" : "off")
    Accessible.description: "Left click toggles keep awake. Right click toggles Do Not Disturb."
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Menu) { DndService.toggle(); event.accepted = true; }
    }
    Rectangle {
        anchors { right: parent.right; top: parent.top; margins: 3 }
        width: 4; height: 4; radius: 2
        color: Theme.accent
        visible: DndService.isEnabled
    }
    

    Keys.onReturnPressed: DesktopState.caffeine = !DesktopState.caffeine
    Keys.onSpacePressed: DesktopState.caffeine = !DesktopState.caffeine


    readonly property bool isCaffeineActive: DesktopState.caffeine

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            color: idleInhibitorWidget.isCaffeineActive ? Theme.accent : Theme.subtext0
            font.family: Theme.fontMain
            font.pixelSize: 14
            renderType: Text.NativeRendering
            text: idleInhibitorWidget.isCaffeineActive ? "󰅶" : "󰛊"
        }
    }

    // Native Wayland Idle Inhibitor. Toggling this dynamically instantiates/destroys it,
    // sending idle inhibitor signals directly to the Wayland compositor.
    Loader {
        active: idleInhibitorWidget.isCaffeineActive
        sourceComponent: Component {
            IdleInhibitor {}
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) DndService.toggle();
            else DesktopState.caffeine = !DesktopState.caffeine;
        }
    }
}
