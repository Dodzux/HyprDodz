pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Row {
    id: group
    required property var keys
    required property var registry
    property bool hoverSession: false
    spacing: 0
    height: 28
    Repeater {
        id: slots
        model: ScriptModel { values: group.keys }
        delegate: Item {
            id: slot
            required property string modelData
            readonly property real naturalWidth: loader.item && loader.item.visible ? loader.item.width : 0
            width: naturalWidth > 0 ? naturalWidth + 6 : 0
            height: 28
            Loader {
                id: loader
                anchors { left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter }
                sourceComponent: group.registry[slot.modelData] || null
                onLoaded: if (item.groupHoverHold !== undefined) item.groupHoverHold = Qt.binding(() => group.hoverSession)
            }
        }
    }
}
