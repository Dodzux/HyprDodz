import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

BarItem {
    id: idleInhibitorWidget

    width: contentRow.implicitWidth + 16
    
    HoverHandler { id: hover }
    Accessible.name: "Keep awake " + (DesktopState.caffeine ? "on" : "off")
    Accessible.description: "Toggle keep awake."

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
        acceptedButtons: Qt.LeftButton
        onClicked: DesktopState.caffeine = !DesktopState.caffeine
    }
}
