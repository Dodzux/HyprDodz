pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs
import qs.services

Row {
    id: group
    required property string groupKey
    required property var keys
    required property var registry
    property bool hoverSession: false
    signal dropRequested(string key, real globalX, real globalY)
    function acceptControlDrop(key, globalX, globalY) {
        var position = mapFromGlobal(globalX, globalY);
        if (position.x < 0 || position.x > width || position.y < 0 || position.y > height) return false;
        var before = "";
        for (var i = 0; i < slots.count; ++i) {
            var item = slots.itemAt(i);
            if (item && position.x < item.x + item.width) { before = item.controlKey; break; }
        }
        Qt.callLater(() => DesktopState.moveControl(key, groupKey, before));
        return true;
    }
    property int sizingRevision: 0
    readonly property real targetWidth: {
        sizingRevision;
        var total = 0, visibleCount = 0;
        for (var i = 0; i < slots.count; ++i) {
            var slot = slots.itemAt(i);
            if (slot && slot.desiredWidth > 0) { total += slot.desiredWidth + 6; visibleCount++; }
        }
        if (DesktopState.editing) { total += 38; visibleCount++; }
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
            readonly property string controlKey: modelData
            readonly property real naturalWidth: DesktopState.editing ? 48 : loader.item && loader.item.visible ? loader.item.width : 0
            readonly property real desiredWidth: DesktopState.editing ? 48 : loader.item && loader.item.visible
                ? (loader.item.panelTargetWidth !== undefined ? loader.item.panelTargetWidth : naturalWidth) : 0
            width: naturalWidth > 0 ? naturalWidth + 6 : 0
            height: 28
            clip: !mover.drag.active
            Loader {
                id: loader
                anchors.left: parent.left
                anchors.leftMargin: 3
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: group.registry[slot.controlKey] || null
                enabled: !DesktopState.editing
                onLoaded: {
                    if (item.holdDetails !== undefined)
                        item.holdDetails = Qt.binding(() => group.hoverSession);
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: Theme.widgetRadius
                color: drop.containsDrag ? Theme.bgSelection : "transparent"
                border.width: DesktopState.editing ? 1 : 0
                border.color: drop.containsDrag ? Theme.accent : Theme.glassBorder
                Text {
                    anchors { right: parent.right; top: parent.top }
                    text: "⋮"
                    color: Theme.accent
                    font.pixelSize: 10
                    visible: DesktopState.editing
                }
            }
            DropArea {
                id: drop
                anchors.fill: parent
                enabled: DesktopState.editing
                keys: ["bar-control"]

            }
            Item {
                id: dragToken
                property string controlKey: slot.controlKey
                x: slot.width / 2; y: slot.height / 2
                width: 1; height: 1
                Drag.active: mover.drag.active
                Drag.source: dragToken
                Drag.keys: ["bar-control"]
                Drag.hotSpot: Qt.point(0, 0)
                Rectangle {
                    visible: mover.drag.active
                    width: 34; height: 28
                    x: -17; y: -14
                    radius: Theme.widgetRadius
                    color: Theme.bgSelection
                    border.color: Theme.accent
                    Text { anchors.centerIn: parent; text: "↔"; color: Theme.text }
                }
            }
            MouseArea {
                id: mover
                anchors.fill: parent
                enabled: DesktopState.editing
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                drag.target: dragToken
                drag.threshold: 5
                onReleased: mouse => {
                    var point = mover.mapToGlobal(mouse.x, mouse.y);
                    if (mover.drag.active) group.dropRequested(slot.controlKey, point.x, point.y);
                    dragToken.Drag.cancel();
                    dragToken.x = slot.width / 2; dragToken.y = slot.height / 2;
                }
                onCanceled: { dragToken.x = slot.width / 2; dragToken.y = slot.height / 2; }
            }
        }
    }
    Rectangle {
        width: DesktopState.editing ? 38 : 0
        height: 28
        visible: DesktopState.editing
        radius: Theme.widgetRadius
        color: endDrop.containsDrag ? Theme.bgSelection : "transparent"
        border.color: Theme.borderMuted
        Text { anchors.centerIn: parent; text: "+"; color: Theme.subtext0 }
        DropArea {
            id: endDrop
            anchors.fill: parent
            keys: ["bar-control"]

        }
    }
}
