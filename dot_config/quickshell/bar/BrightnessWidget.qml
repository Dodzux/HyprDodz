import QtQuick
import Quickshell
import qs
import qs.services

BarItem {
    id: brightnessWidget
    readonly property var controller: root.brightnessController
    readonly property bool expanded: detailsShown
    panelTargetWidth: brightnessIcon.implicitWidth + 16 + ((detailsRequested || detailsShown) ? brightnessText.implicitWidth + 4 : 0)
    width: contentRow.implicitWidth + 16
    Accessible.role: Accessible.Button
    Accessible.name: "Brightness " + controller.brightnessPct + " percent, Night Light " + (controller.nightLightOn ? "on" : "off")
    Accessible.description: "Click for Night Light and Extra Dim; scroll to change brightness."
    Accessible.onPressAction: brightnessWidget.toggleMenu()
    selected: menu.visible
    holdDetails: menu.visible
    function toggleMenu() {
        if (!menu.visible)
            controller.refreshNightLight();
        menu.visible = !menu.visible;
    }
    function choose(index) {
        if (controller.nightLightBusy)
            return;
        if (index === 0)
            controller.toggleNightLight();
        else
            controller.toggleExtraDim();
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_N) {
            controller.toggleNightLight();
            event.accepted = true;
        }
    }
    onHoveredChanged: {
        if (hovered) {
            controller.refreshBrightness(false);
            controller.refreshNightLight();
        }
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            controller.refreshBrightness(false);
            controller.refreshNightLight();
        }
    }
    Keys.onReturnPressed: toggleMenu()
    Keys.onSpacePressed: toggleMenu()
    Keys.onUpPressed: controller.adjustBrightness(5)
    Keys.onDownPressed: controller.adjustBrightness(-5)

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: brightnessWidget.expanded ? 4 : 0
        Behavior on spacing {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
        Text {
            id: brightnessIcon
            anchors.verticalCenter: parent.verticalCenter
            text: brightnessWidget.controller.nightLightOn ? "" : brightnessWidget.controller.extraDimOn ? "󰃝" : "󰃠"
            color: Theme.accent
            font.family: Theme.fontMain
            font.pixelSize: 14
            renderType: Text.NativeRendering
        }
        Text {
            id: brightnessText
            anchors.verticalCenter: parent.verticalCenter
            text: brightnessWidget.controller.brightnessPct + "%"
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: 10
            font.weight: Font.Bold
            renderType: Text.NativeRendering
            clip: true
            width: brightnessWidget.expanded ? implicitWidth : 0
            opacity: brightnessWidget.expanded ? 1 : 0
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
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                brightnessWidget.controller.toggleNightLight();
            else
                brightnessWidget.toggleMenu();
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y !== 0)
                brightnessWidget.controller.adjustBrightness(wheel.angleDelta.y > 0 ? 5 : -5);
        }
    }

    PopupWindow {
        id: menu
        objectName: "display-modes-menu"
        property int selectedIndex: 0
        visible: false
        grabFocus: true
        anchor.item: brightnessWidget
        anchor.rect.x: BarState.popupX(brightnessWidget.width)
        anchor.rect.y: BarState.popupY(brightnessWidget.height)
        anchor.gravity: BarState.popupGravity
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
                Keys.onUpPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 2
                Keys.onDownPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 2
                Keys.onTabPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 2
                Keys.onBacktabPressed: menu.selectedIndex = (menu.selectedIndex + 1) % 2
                Keys.onReturnPressed: brightnessWidget.choose(menu.selectedIndex)
                Keys.onSpacePressed: brightnessWidget.choose(menu.selectedIndex)
                Text {
                    width: parent.width
                    height: 28
                    text: "Display"
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: [
                        {
                            name: "Night Light",
                            icon: "",
                            detail: "Gentle warmth · 5500 K"
                        },
                        {
                            name: "Extra Dim",
                            icon: "󰃝",
                            detail: "65% display brightness"
                        }
                    ]
                    Rectangle {
                        id: modeRow
                        required property var modelData
                        required property int index
                        objectName: index === 0 ? "night-light-toggle" : "extra-dim-toggle"
                        readonly property bool activeMode: index === 0 ? brightnessWidget.controller.nightLightOn : brightnessWidget.controller.extraDimOn
                        width: content.width
                        height: 56
                        radius: 10
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
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: modelData.name
                        Accessible.checked: activeMode
                        Accessible.onPressAction: brightnessWidget.choose(modeRow.index)
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
                                text: modeRow.modelData.detail
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
                            cursorShape: brightnessWidget.controller.nightLightBusy ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onHoveredChanged: if (hovered)
                                menu.selectedIndex = modeRow.index
                        }
                        TapHandler {
                            onTapped: brightnessWidget.choose(modeRow.index)
                        }
                    }
                }
                Text {
                    width: parent.width
                    visible: brightnessWidget.controller.nightLightError !== "" || brightnessWidget.controller.nightLightBusy
                    text: brightnessWidget.controller.nightLightBusy ? "Applying…" : brightnessWidget.controller.nightLightError
                    color: brightnessWidget.controller.nightLightError !== "" ? Theme.error : Theme.subtext0
                    font.family: Theme.fontMain
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
