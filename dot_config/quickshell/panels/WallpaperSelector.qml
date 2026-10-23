import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services

PanelWindow {
    id: wallpaperWindow
    visible: false
    function choose(item) {
        Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/awww_transition.sh", item.path]);
        visible = false;
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-wallpaper-selector"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    

    property var wallpapers: []
    property var filteredWallpapers: {
        var q = searchInput.text.toLowerCase().trim()
        return wallpapers.filter(function(item) {
            return !q || item.name.toLowerCase().includes(q);
        }).sort(function(a, b) {
            // Numbered variants belong under the wallpaper name (Rain World → R).
            var nameA = a.name.toLowerCase().replace(/^\d+[\s._-]+/, "");
            var nameB = b.name.toLowerCase().replace(/^\d+[\s._-]+/, "");
            return nameA.localeCompare(nameB)
                || a.name.toLowerCase().localeCompare(b.name.toLowerCase())
                || a.path.localeCompare(b.path);
        });
    }

    Process {
        id: findProc
        command: ["python3", Quickshell.shellDir + "/scripts/desktop_data.py", "palettes",
                  "--cache", Quickshell.env("HOME") + "/.cache/quickshell/wallpaper-palettes"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { wallpaperWindow.wallpapers = JSON.parse(this.text); }
                catch (error) { console.warn("Wallpaper palette:", error); }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: wallpaperWindow.visible = false
    }

    Rectangle {
        id: panelCard
        Behavior on height { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
        width: 840
        height: Math.min(600, Math.max(160, 12 + headerBox.height + 12 + gridList.contentHeight + 12))
        anchors.centerIn: parent

        color: Theme.glassBg
        radius: 14
        antialiasing: true
        border.color: Theme.glassBorder
        border.width: 1

        opacity: wallpaperWindow.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }

        transform: Translate {
            y: wallpaperWindow.visible ? 0 : 16
            Behavior on y { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
        }

        MouseArea { 
            anchors.fill: parent
            onClicked: searchInput.forceActiveFocus() 
        } // Block background click and keep focus

        Rectangle {
            id: headerBox
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            height: 46
            radius: 8
            color: Theme.glassBg
            border.width: 0

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                spacing: 10

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Theme.text
                    selectByMouse: true
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.onAccent
                    font.family: Theme.fontMain
                    font.pixelSize: 14
                    focus: wallpaperWindow.visible

                    Text {
                        anchors.fill: parent
                        text: "Search wallpapers..."
                        color: Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 14
                        visible: parent.text.length === 0
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: wallpaperWindow.visible = false
                    Keys.onDownPressed:   gridList.moveCurrentIndexDown()
                    Keys.onUpPressed:     gridList.moveCurrentIndexUp()
                    Keys.onRightPressed:  gridList.moveCurrentIndexRight()
                    Keys.onLeftPressed:   gridList.moveCurrentIndexLeft()
                    Keys.onReturnPressed: {
                        if (wallpaperWindow.filteredWallpapers.length > 0) {
                            var entry = wallpaperWindow.filteredWallpapers[gridList.currentIndex]
                            if (entry) {
                                wallpaperWindow.choose(entry)
                                wallpaperWindow.visible = false
                            }
                        }
                    }
                }
            }
        }

        GridView {
            id: gridList
            anchors {
                top: headerBox.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 12
                bottomMargin: 12
                topMargin: 12
            }
            
            cellWidth: Math.floor((width - 8) / 4)
            cellHeight: Math.floor((cellWidth / 16) * 9) + 61
            
            model: ScriptModel {
                values: wallpaperWindow.filteredWallpapers
                objectProp: "path"
                onValuesChanged: Qt.callLater(() => { gridList.currentIndex = values.length ? 0 : -1; })
            }
            add: Transition { NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.motionNormal } }
            remove: Transition { NumberAnimation { properties: "opacity"; to: 0; duration: Theme.motionExit } }
            displaced: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            currentIndex: 0
            clip: true
            highlightMoveDuration: Theme.launcherSelectionDuration
            highlight: Item {
                width: gridList.cellWidth
                height: gridList.cellHeight
                Rectangle {
                    anchors { fill: parent; margins: 6 }
                    radius: 10
                    antialiasing: true
                    color: Theme.launcherSelectionBg
                    border.color: Theme.launcherSelectionBorder
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                }
            }
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                visible: gridList.contentHeight > gridList.height
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    // Wallpaper accent (set live by sync_border.py); brighter
                    // while it is being dragged. Same as the app launcher.
                    color: parent.pressed ? Qt.lighter(Theme.accent, 1.3) : Theme.accent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            delegate: Item {
                id: wallpaperTile
                width: gridList.cellWidth
                height: gridList.cellHeight
                
                required property var modelData
                required property int index
                readonly property bool highlighted: gridList.currentIndex === index || itemHover.hovered

                Rectangle {
                    anchors { fill: parent; margins: 6 }
                    radius: 10
                    color: itemHover.hovered && gridList.currentIndex !== index ? Theme.launcherHoverBg : "transparent"
                    border.color: "transparent"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { gridList.currentIndex = wallpaperTile.index; wallpaperWindow.choose(wallpaperTile.modelData); }
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 6
                            radius: 6
                            color: "transparent"
                            clip: true
                            
                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData.path
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize: Qt.size(240, 135)
                            }
                        }
                        
                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4
                            Repeater {
                                model: wallpaperTile.modelData.swatches || []
                                Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: index === 0 ? 22 : 14
                                    height: 8
                                    radius: 4
                                    color: modelData
                                    border.width: 1
                                    border.color: Theme.glassBorder
                                }
                            }
                        }

                        Text {
                            text: modelData.name
                            color: wallpaperTile.highlighted ? Theme.accent : Theme.text
                            Behavior on color { ColorAnimation { duration: Theme.launcherSelectionDuration; easing.type: Easing.OutCubic } }
                            font.family: Theme.fontMain
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            Layout.margins: 6
                            Layout.topMargin: 0
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    HoverHandler { id: itemHover }

                }
            }
            
            Text {
                anchors.centerIn: parent
                text: searchInput.text.length > 0 ? "No wallpapers match your search" : "No wallpapers found"
                color: Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 13
                visible: gridList.count === 0
            }
        }
        

    }

    function toggle(scr) {
        if (wallpaperWindow.visible) {
            wallpaperWindow.visible = false;
            return;
        }
        if (scr) {
            wallpaperWindow.screen = scr;
        }
        searchInput.text = "";
        if (wallpaperWindow.wallpapers.length === 0 && !findProc.running) {
            findProc.running = true;
        }
        wallpaperWindow.visible = true;
    }
}
