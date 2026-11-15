import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs

Grid {
    id: systemTrayWidget

    property bool vertical: false
    columns: vertical ? 1 : Math.max(1, SystemTray.items.values.length)
    spacing: 6

    required property var parentWindow

    Repeater {
        model: SystemTray.items

        BarItem {   // shared hover / focus / press look
            id: trayItem
            required property var modelData

            width: 28

            Keys.onReturnPressed: modelData.activate()
            Keys.onSpacePressed: modelData.activate()

            Image {
                anchors.centerIn: parent
                source: modelData.icon
                width: 22
                height: 22
                sourceSize: Qt.size(22, 22)
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: (mouse) => {
                    if (mouse.button !== Qt.RightButton && !modelData.onlyMenu) {
                        modelData.activate();
                        return;
                    }
                    if (modelData.hasMenu) {
                        var pos=trayItem.mapToItem(systemTrayWidget.parentWindow.contentItem,trayItem.width/2,0);
                        root.showTrayMenu(systemTrayWidget.parentWindow.screen,modelData,systemTrayWidget.parentWindow.screenX + pos.x,systemTrayWidget.parentWindow.screenY + pos.y);
                    }
                }
            }
        }
    }
}
