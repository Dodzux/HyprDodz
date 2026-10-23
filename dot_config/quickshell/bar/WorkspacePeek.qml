pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs

Rectangle {
    id: peek
    property string workspaceId: "1"
    property var clients: []
    signal selected(var client)
    readonly property var windows: clients.filter(c => c.workspace === workspaceId)
    readonly property real aspect: windows.length ? (windows[0].aspect || 1.6) : 1.6
    implicitWidth: 184
    implicitHeight: Math.round((implicitWidth - 16) / aspect) + 16
    color: Theme.glassBg
    radius: 10
    border.color: Theme.glassBorder
    antialiasing: true

    Item {
        id: desktop
        anchors { fill: parent; margins: 8 }
        clip: true
        Repeater {
            model: peek.windows
            Rectangle {
                id: tile
                required property var modelData
                x: modelData.x * desktop.width
                y: modelData.y * desktop.height
                width: Math.max(0, Math.min(desktop.width - x, modelData.w * desktop.width))
                height: Math.max(0, Math.min(desktop.height - y, modelData.h * desktop.height))
                radius: 4
                color: hover.hovered ? Theme.launcherSelectionBg : "transparent"
                border.color: hover.hovered ? Theme.accent : Theme.borderMuted
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                readonly property var app: DesktopEntries.heuristicLookup(modelData.class === "org.yazi.fm" ? "yazi" : modelData.class)
                Image {
                    anchors.centerIn: parent
                    width: Math.max(0, Math.min(18, parent.width - 4, parent.height - 4))
                    height: width
                    source: {
                        var icon = tile.app && tile.app.icon ? tile.app.icon : "application-x-executable";
                        return icon.startsWith("/") ? "file://" + icon : "image://icon/" + icon;
                    }
                    sourceSize: Qt.size(18, 18)
                    fillMode: Image.PreserveAspectFit
                }
                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: peek.selected(tile.modelData) }
            }
        }
    }
}
