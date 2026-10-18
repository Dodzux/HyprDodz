import QtQuick
import qs

Rectangle {
    id: button
    property string label: ""
    property bool chosen: false
    signal clicked()
    implicitWidth: labelText.implicitWidth + 24
    implicitHeight: 34
    radius: Theme.widgetRadius
    color: chosen || hover.hovered ? Theme.hoverBg : "transparent"
    border.width: 1
    border.color: chosen || activeFocus ? Theme.accent : Theme.glassBorder
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.4
    scale: press.pressed ? 0.98 : 1
    Behavior on scale { NumberAnimation { duration: Theme.motionFast } }
    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.onPressAction: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()
    Text {
        id: labelText
        anchors.centerIn: parent
        text: button.label
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: Theme.bodySize
    }
    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    MouseArea { id: press; anchors.fill: parent; onClicked: button.clicked() }
}
