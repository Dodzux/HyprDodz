import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services

BarItem {
    id: sysMonitorWidget

    panelTargetWidth: cpuIcon.implicitWidth + 20 + ((detailsRequested || detailsShown) ? cpuText.implicitWidth + memIcon.implicitWidth + memText.implicitWidth + 18 : 0)
    width: contentLayout.implicitWidth + 20
    
    readonly property bool isHoveredOrFocused: detailsShown

    


    property bool showMemGb: true

    function openMonitor() {
        Quickshell.execDetached([
            "systemd-run", "--user", "--scope", "--quiet", "--collect",
            "--slice=app.slice", "--description=btop", "kitty", "-e", "btop"
        ]);
    }
    Keys.onReturnPressed: openMonitor()
    Keys.onSpacePressed: openMonitor()
    TapHandler { onTapped: sysMonitorWidget.openMonitor() }

    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: sysMonitorWidget.isHoveredOrFocused ? 10 : 0

        // CPU Section
        Row {
            spacing: sysMonitorWidget.isHoveredOrFocused ? 4 : 0

            Text {
                id: cpuIcon
                text: ""
                anchors.verticalCenter: parent.verticalCenter
                color: SysMonitorService.cpuUsage >= 85 ? Theme.error : Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 13
                renderType: Text.NativeRendering
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                id: cpuText
                width: sysMonitorWidget.isHoveredOrFocused ? implicitWidth : 0
                opacity: sysMonitorWidget.isHoveredOrFocused ? 1 : 0
                clip: true
                Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                anchors.verticalCenter: parent.verticalCenter
                text: SysMonitorService.cpuUsage.toString().padStart(2, '0') + "%"
                color: SysMonitorService.cpuUsage >= 85 ? Theme.error : Theme.text
                font.family: Theme.fontMain
                font.pixelSize: 10
                font.weight: Font.Bold
                renderType: Text.NativeRendering
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Memory Section
        Row {
            width: sysMonitorWidget.isHoveredOrFocused ? implicitWidth : 0
            opacity: sysMonitorWidget.isHoveredOrFocused ? 1 : 0
            clip: true
            Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
            spacing: 4

            Text {
                id: memIcon
                text: "󰘚"
                anchors.verticalCenter: parent.verticalCenter
                color: SysMonitorService.memUsage >= 85 ? Theme.error : Theme.subtext0
                font.family: Theme.fontMain
                font.pixelSize: 13
                renderType: Text.NativeRendering
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            Text {
                id: memText
                anchors.verticalCenter: parent.verticalCenter
                text: sysMonitorWidget.showMemGb ? (SysMonitorService.memUsed || (SysMonitorService.memUsage + "%")) : (SysMonitorService.memUsage.toString().padStart(2, '0') + "%")
                color: SysMonitorService.memUsage >= 85 ? Theme.error : Theme.text
                font.family: Theme.fontMain
                font.pixelSize: 10
                font.weight: Font.Bold
                renderType: Text.NativeRendering
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
