import QtQuick
import qs

BarItem {
    id: brightnessWidget
    readonly property var controller: root.brightnessController
    readonly property bool expanded: hovered || activeFocus
    width: contentRow.implicitWidth + 16

    onHoveredChanged: { if (hovered) controller.refreshBrightness(false); }
    onActiveFocusChanged: { if (activeFocus) controller.refreshBrightness(false); }
    Keys.onReturnPressed: controller.requestBrightness()
    Keys.onSpacePressed: controller.requestBrightness()
    Keys.onUpPressed: controller.adjustBrightness(5)
    Keys.onDownPressed: controller.adjustBrightness(-5)

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: brightnessWidget.expanded ? 4 : 0
        Behavior on spacing { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰃠"
            color: Theme.accent
            font.family: Theme.fontMain
            font.pixelSize: 14
            renderType: Text.NativeRendering
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: brightnessWidget.controller.brightnessPct + "%"
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: 10
            font.weight: Font.Bold
            renderType: Text.NativeRendering
            clip: true
            width: brightnessWidget.expanded ? implicitWidth : 0
            opacity: brightnessWidget.expanded ? 1 : 0
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: brightnessWidget.controller.requestBrightness()
        onWheel: wheel => {
            if (wheel.angleDelta.y !== 0)
                brightnessWidget.controller.adjustBrightness(wheel.angleDelta.y > 0 ? 5 : -5);
        }
    }
}
