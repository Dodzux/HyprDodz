pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Row {
    id: group
    required property var keys
    required property var registry
    property bool hoverSession: false
    property int sizingRevision: 0
    readonly property real targetWidth: {
        sizingRevision;
        var total = 0;
        for (var i = 0; i < slots.count; ++i) {
            var slot = slots.itemAt(i);
            if (slot && slot.desiredWidth > 0) total += slot.desiredWidth + 6;
        }
        return total;
    }
    spacing: 0
    height: 28
    Repeater {
        id: slots
        model: ScriptModel { values: group.keys }
        onItemAdded: group.sizingRevision++
        onItemRemoved: group.sizingRevision++
        delegate: Item {
            id: slot
            required property string modelData
            readonly property real naturalWidth: loader.item && loader.item.visible ? loader.item.width : 0
            readonly property real desiredWidth: loader.item && loader.item.visible
                ? (loader.item.panelTargetWidth !== undefined ? loader.item.panelTargetWidth : naturalWidth) : 0
            width: naturalWidth > 0 ? naturalWidth + 6 : 0
            height: 28
            Loader {
                id: loader
                anchors { left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter }
                sourceComponent: group.registry[slot.modelData] || null
                onLoaded: if (item.holdDetails !== undefined) item.holdDetails = Qt.binding(() => group.hoverSession)
            }
        }
    }
}
