pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower as Up
import qs

// Native PowerProfiles supplies live state; one short-lived command per click
// reports permission/daemon failures without optimistically changing the icon.
BarItem {
    id: widget
    objectName: "battery-performance-selector"
    panelTargetWidth: batteryIcons.implicitWidth + 16 + ((detailsRequested || detailsShown) ? batteryText.implicitWidth + 4 : 0)
    width: contentRow.implicitWidth + 16
    selected: menu.visible

    readonly property var bat: Up.UPower.displayDevice
    readonly property bool hasBat: bat ? bat.ready && bat.isPresent : false
    readonly property bool pluggedIn: !Up.UPower.onBattery
    readonly property int batPct: hasBat ? Math.round(Math.max(0, Math.min(1, bat.percentage)) * 100) : 0

    readonly property string batteryGlyph: {
        if (!hasBat)
            return "󰂎";
        if (pluggedIn)
            return "󰚥";
        var levels = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        return levels[Math.ceil(batPct / 10)];
    }

    readonly property bool isHoveredOrFocused: detailsShown
    visible: hasBat

    readonly property var modes: [
        {
            name: "Silent",
            key: "power-saver",
            value: Up.PowerProfile.PowerSaver,
            icon: "󰌪",
            detail: "lower power · Quieter fans"
        },
        {
            name: "Performance",
            key: "balanced",
            value: Up.PowerProfile.Balanced,
            icon: "󰓅",
            detail: "Balanced speed and fan noise"
        },
        {
            name: "Turbo",
            key: "performance",
            value: Up.PowerProfile.Performance,
            icon: "",
            detail: "Maximum performance · louder fans"
        }
    ]
    readonly property int currentIndex: modes.findIndex(m => m.value === Up.PowerProfiles.profile)
    readonly property var currentMode: modes[Math.max(0, currentIndex)]
    readonly property bool busy: applyMode.running
    property string errorMessage: ""

    Accessible.role: Accessible.Button
    Accessible.name: "Battery " + batPct + " percent, " + (pluggedIn ? "plugged in, " : "") + currentMode.name + " mode"
    Accessible.onPressAction: widget.toggleMenu()

    function toggleMenu() {
        if (menu.visible) {
            menu.visible = false;
            return;
        }
        errorMessage = "";
        menu.selectedIndex = Math.max(0, currentIndex);
        menu.visible = true;
    }

    function choose(index) {
        if (busy || index < 0 || index >= modes.length)
            return;
        if (index === 2 && !Up.PowerProfiles.hasPerformanceProfile)
            return;
        if (modes[index].value === Up.PowerProfiles.profile) {
            menu.visible = false;
            return;
        }
        errorMessage = "";
        applyMode.command = ["powerprofilesctl", "set", modes[index].key];
        applyMode.running = true;
    }

    Keys.onReturnPressed: toggleMenu()
    Keys.onSpacePressed: toggleMenu()
    Keys.onEscapePressed: menu.visible = false
    TapHandler {
        onTapped: widget.toggleMenu()
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: isHoveredOrFocused ? 4 : 0

        Behavior on spacing {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: batteryIcons
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                id: modeIcon
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                text: widget.currentMode.icon
                color: Theme.accent
                font.family: Theme.fontMain
                font.pixelSize: 14
                renderType: Text.NativeRendering
                opacity: widget.busy ? 0.5 : 1
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motionFast
                    }
                }
            }

            Text {
                id: batteryIcon
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                color: widget.pluggedIn ? Theme.success : Theme.text
                font.family: Theme.fontMain
                font.pixelSize: 14
                renderType: Text.NativeRendering
                text: widget.batteryGlyph
            }
        }

        Text {
            id: batteryText
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: 10
            font.weight: Font.Bold
            renderType: Text.NativeRendering

            clip: true
            width: isHoveredOrFocused ? implicitWidth : 0
            opacity: isHoveredOrFocused ? 1.0 : 0.0

            Behavior on width {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                }
            }

            text: {
                if (!hasBat)
                    return "00%";
                return batPct.toString().padStart(2, '0') + "%";
            }
        }
    }

    Process {
        id: applyMode
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0)
                menu.visible = false;
            else
                widget.errorMessage = "Could not change mode. Please try again.";
        }
    }

    PopupWindow {
        id: menu
        objectName: "performance-menu"
        property int selectedIndex: 0
        visible: false
        grabFocus: true
        anchor.item: widget
        anchor.rect.x: widget.width / 2
        anchor.rect.y: widget.height + 12
        anchor.gravity: Edges.Bottom
        color: "transparent"
        implicitWidth: 284
        implicitHeight: content.implicitHeight + 24
        onVisibleChanged: if (visible) {
            content.forceActiveFocus();
            reveal.restart();
        }

        ParallelAnimation {
            id: reveal
            NumberAnimation {
                target: card
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.motionNormal
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: card
                property: "scale"
                from: 0.97
                to: 1
                duration: Theme.motionNormal
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 16
            color: Theme.glassBg
            border.color: Theme.glassBorder
            border.width: 1

            Column {
                id: content
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 12
                }
                spacing: 5
                focus: true
                Keys.onEscapePressed: menu.visible = false
                Keys.onUpPressed: menu.selectedIndex = (menu.selectedIndex + 2) % 3
                Keys.onDownPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 3
                Keys.onTabPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 3
                Keys.onBacktabPressed: menu.selectedIndex = (menu.selectedIndex + 2) % 3
                Keys.onReturnPressed: widget.choose(menu.selectedIndex)
                Keys.onSpacePressed: widget.choose(menu.selectedIndex)

                Text {
                    width: parent.width
                    height: 28
                    text: "Battery & performance"
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: widget.batPct + "% · " + (widget.pluggedIn ? "Plugged in" : "On battery")
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.bodySize
                }
                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.hoverBg
                    Rectangle {
                        width: parent.width * widget.batPct / 100
                        height: parent.height
                        radius: 3
                        color: widget.pluggedIn ? Theme.success : Theme.accent
                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.motionNormal
                            }
                        }
                    }
                }
                Text {
                    width: parent.width
                    text: {
                        var seconds = widget.hasBat ? (widget.pluggedIn ? widget.bat.timeToFull : widget.bat.timeToEmpty) : 0;
                        if (widget.batPct >= 99 && widget.pluggedIn)
                            return "Fully charged";
                        if (!(seconds > 0))
                            return "Time estimate unavailable";
                        var minutes = Math.ceil(seconds / 60);
                        return Math.floor(minutes / 60) + "h " + minutes % 60 + "m " + (widget.pluggedIn ? "until full" : "remaining");
                    }
                    color: Theme.subtext0
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.captionSize
                }

                Repeater {
                    model: widget.modes
                    Rectangle {
                        id: modeRow
                        required property var modelData
                        required property int index
                        objectName: "performance-mode-" + modelData.key
                        readonly property bool available: index !== 2 || Up.PowerProfiles.hasPerformanceProfile
                        readonly property bool activeMode: Up.PowerProfiles.profile === modelData.value
                        width: content.width
                        height: 56
                        radius: 10
                        opacity: available ? 1 : 0.4
                        color: menu.selectedIndex === index ? Theme.launcherSelectionBg : "transparent"
                        border.color: menu.selectedIndex === index ? Theme.launcherSelectionBorder : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motionFast
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: Theme.motionFast
                            }
                        }

                        Accessible.role: Accessible.RadioButton
                        Accessible.name: modelData.name
                        Accessible.checked: activeMode
                        Accessible.onPressAction: widget.choose(modeRow.index)

                        Text {
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modeRow.modelData.icon
                            color: modeRow.activeMode ? Theme.accent : Theme.text
                            font.family: Theme.fontMain
                            font.pixelSize: 20
                        }
                        Column {
                            x: 46
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                text: modeRow.modelData.name
                                color: modeRow.activeMode ? Theme.accent : Theme.text
                                font.family: Theme.fontMain
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: modeRow.available ? modeRow.modelData.detail : "Unavailable on this system"
                                color: Theme.subtext0
                                font.family: Theme.fontMain
                                font.pixelSize: 9
                            }
                        }
                        Text {
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            text: modeRow.activeMode ? "✓" : ""
                            color: Theme.accent
                            font.pixelSize: 14
                        }
                        HoverHandler {
                            cursorShape: modeRow.available && !widget.busy ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onHoveredChanged: if (hovered)
                                menu.selectedIndex = modeRow.index
                        }
                        TapHandler {
                            onTapped: widget.choose(modeRow.index)
                        }
                    }
                }

                Text {
                    width: parent.width
                    visible: widget.errorMessage !== "" || widget.busy
                    text: widget.busy ? "Applying…" : widget.errorMessage
                    color: widget.errorMessage !== "" ? Theme.error : Theme.subtext0
                    font.family: Theme.fontMain
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    visible: Up.PowerProfiles.degradationReason !== Up.PerformanceDegradationReason.None
                    text: Up.PowerProfiles.degradationReason === Up.PerformanceDegradationReason.HighTemperature ? "Performance is limited by temperature." : "Performance is limited by lap detection."
                    color: Theme.subtext0
                    font.family: Theme.fontMain
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
