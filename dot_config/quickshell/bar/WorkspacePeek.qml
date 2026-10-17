import QtQuick
import Quickshell
import qs

Rectangle {
    id: peek
    property string workspaceId: "1"
    property var clients: []
    signal selected(var client)
    readonly property var windows: clients.filter(c => c.workspace === workspaceId)
    color: Theme.glassBg
    radius: 12
    border.color: Theme.launcherSelectionBorder
    implicitWidth: 220
    implicitHeight: 150

    Text {
        x: 10; y: 9
        text: "Workspace " + peek.workspaceId + " · " + peek.windows.length + " apps"
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: 10
    }
    Rectangle {
        id: desktop
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; margins: 9; topMargin: 29; bottomMargin: 23 }
        radius: 7
        color: "transparent"
        border.color: Theme.glassBorder
        clip: true
        Repeater {
            model: peek.windows
            Rectangle {
                id: tile
                required property var modelData
                x: modelData.x * desktop.width
                y: modelData.y * desktop.height
                width: Math.min(Math.max(0, desktop.width - x), Math.max(24, modelData.w * desktop.width))
                height: Math.min(Math.max(0, desktop.height - y), Math.max(24, modelData.h * desktop.height))
                radius: 5
                color: hover.hovered ? Theme.launcherSelectionBg : "transparent"
                border.color: hover.hovered ? Theme.accent : Theme.glassBorder
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
                readonly property var app: DesktopEntries.heuristicLookup(modelData.class === "org.yazi.fm" ? "yazi" : modelData.class)
                Image {
                    anchors.centerIn: parent
                    width: Math.min(22, Math.max(0, parent.width - 4))
                    height: Math.min(22, Math.max(0, parent.height - 4))
                    source: {
                        var icon = tile.app && tile.app.icon ? tile.app.icon : "application-x-executable";
                        return icon.startsWith("/") ? icon : "image://icon/" + icon;
                    }
                    sourceSize: Qt.size(22, 22)
                    fillMode: Image.PreserveAspectFit
                }
                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: peek.selected(tile.modelData) }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: peek.windows.length === 0
            text: "Empty workspace"
            color: Theme.subtext0
            font.family: Theme.fontMain
            font.pixelSize: 11
        }
    }
    Text {
        anchors { left: parent.left; bottom: parent.bottom; margins: 9 }
        text: "Click an app to focus it"
        color: Theme.subtext0
        font.family: Theme.fontMain
        font.pixelSize: 9
    }
}
