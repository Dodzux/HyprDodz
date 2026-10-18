import QtQuick
import qs
import qs.services

// NetworkWidget — one bar item for the network: connection icon + ↓↑ speeds.
// Merges the old NetworkWidget and NetworkSpeedWidget (both archived in
// ~/.config/config_archive/quickshell/). Click (or Enter/Space from the bar's
// keyboard mode) drops the network panel down from here.
//
// Neutral by default; an arrow turns accent only while traffic flows that way,
// so the item says "something is downloading" without shouting all day.
BarItem {
    id: widget

    required property var parentWindow
    property bool compact: false
    readonly property bool detailsVisible: !compact || detailsShown

    // Above background chatter (DNS, NTP, keepalives) before an arrow lights up.
    readonly property real activityKiB: 8
    readonly property bool downActive: SysMonitorService.downloadSpeed > activityKiB
    readonly property bool upActive: SysMonitorService.uploadSpeed > activityKiB

    function icon() {
        if (!NetworkService.ready) return "󰤮";
        if (NetworkService.type === "ethernet") return "󰈀";
        if (NetworkService.type === "wifi") {
            var s = NetworkService.activeWifi ? NetworkService.activeWifi.signalStrength : 0;
            return s > 0.75 ? "󰤨" : s > 0.5 ? "󰤥" : s > 0.25 ? "󰤢" : "󰤟";
        }
        return NetworkService.wifiEnabled ? "󰤯" : "󰤮";
    }

    // KiB/s from SysMonitorService → "512K" / "1.2M" / "12M"
    function formatSpeed(kib) {
        if (kib < 1000) return Math.round(kib) + "K";
        var mib = kib / 1024;
        return (mib < 10 ? mib.toFixed(1) : Math.round(mib)) + "M";
    }

    function toggle() {
        // Centre of this item in screen coordinates: the bar window starts at
        // its left margin (Bar.qml `margins.left`).
        var r = parentWindow.itemRect(widget);
        root.toggleNetwork(parentWindow.screen, parentWindow.margins.left + r.x + r.width / 2);
    }

    panelTargetWidth: networkIcon.implicitWidth + 16 + ((!compact || detailsRequested || detailsShown) && NetworkService.type !== "none" ? speeds.implicitWidth + 8 : 0)
    width: contentRow.implicitWidth + 16

    Keys.onReturnPressed: toggle()
    Keys.onSpacePressed: toggle()

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: speeds.width > 0 ? 8 : 0

        Text {
            id: networkIcon
            anchors.verticalCenter: parent.verticalCenter
            text: widget.icon()
            color: NetworkService.type === "none" ? Theme.subtext0 : Theme.text
            font.family: Theme.fontMain
            font.pixelSize: 14
        }

        // Speeds only while connected — nothing to measure otherwise.
        Row {
            id: speeds
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            visible: NetworkService.type !== "none"
            width: widget.detailsVisible ? implicitWidth : 0
            opacity: widget.detailsVisible ? 1 : 0
            clip: true
            Behavior on width { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }

            Repeater {
                model: [
                    { glyph: "󰇚", active: widget.downActive, value: SysMonitorService.downloadSpeed },
                    { glyph: "󰕒", active: widget.upActive, value: SysMonitorService.uploadSpeed }
                ]

                delegate: Row {
                    id: speed
                    required property var modelData
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: speed.modelData.glyph
                        color: speed.modelData.active ? Theme.accent : Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 13
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: widget.formatSpeed(speed.modelData.value)
                        color: Theme.text
                        font.family: Theme.fontMain
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }

    TapHandler { onTapped: widget.toggle() }
}
