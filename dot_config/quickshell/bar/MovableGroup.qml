pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Grid {
    id: group
    required property var keys
    required property var registry
    property bool hoverSession: false
    property bool vertical: false
    readonly property bool popupOpen: children.some(child => child.isMenuOpen === true)
    function closePopups() {
        for (var slot of children) {
            var widget = slot.widget;
            if (widget && widget.holdDetails && typeof widget.toggleMenu === "function") widget.toggleMenu();
            if (widget && widget.detailsShown !== undefined) widget.detailsShown = false;
        }
    }
    columns: vertical ? 1 : Math.max(1, keys.length)
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    spacing: 0
    Repeater {
        id: slots
        model: ScriptModel { values: group.keys }
        delegate: Item {
            id: slot
            required property string modelData
            readonly property real naturalWidth: loader.item && loader.item.visible ? loader.item.width : 0
            readonly property var widget: loader.item
            readonly property bool isMenuOpen: !!loader.item && !!loader.item.holdDetails
            width: group.vertical ? 60 : naturalWidth > 0 ? naturalWidth + 6 : 0
            height: group.vertical ? (naturalWidth > 0 ? Math.max(34, loader.item.height + 6) : 0) : 28
            Loader {
                id: loader
                anchors.centerIn: parent
                sourceComponent: group.registry[slot.modelData] || null
                onLoaded: if (item.groupHoverHold !== undefined) item.groupHoverHold = Qt.binding(() => group.hoverSession)
            }
        }
    }
}
