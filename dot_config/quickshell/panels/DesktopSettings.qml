import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services

PanelWindow {
    id: settings
    visible: false
    property string section: "layout"
    property var checks: []
    property string message: ""
    function open(tab, scr) {
        section = tab === "health" || tab === "tools" ? "health" : tab === "help" ? "help" : "layout";
        if (scr) screen = scr;
        visible = true;
        if (section === "health") runHealth();
    }
    function runHealth() { if (!health.running) { checks = []; health.running = true; } }
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-desktop-settings"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    MouseArea { anchors.fill: parent; onClicked: settings.visible = false }
    Process {
        id: health
        command: ["python3", DesktopState.helper, "health"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { var result = JSON.parse(text); settings.checks = Array.isArray(result) ? result : []; settings.message = result.message || ""; }
                catch (e) { settings.message = "Diagnostics did not return a valid result"; }
            }
        }
    }
    Rectangle {
        id: card
        objectName: "desktop-studio-card"
        width: Math.min(800, settings.width - 40)
        height: Math.min(550, settings.height - 80)
        anchors.centerIn: parent
        radius: 14
        color: Theme.glassBg
        border.color: Theme.glassBorder
        border.width: 1
        focus: true
        Keys.onEscapePressed: settings.visible = false
        MouseArea { anchors.fill: parent }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Desktop controls"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 18; font.weight: Font.DemiBold }
                Item { Layout.fillWidth: true }
                DesktopButton { label: "Close"; onClicked: settings.visible = false }
            }
            RowLayout {
                DesktopButton { label: "Bar layout"; chosen: settings.section === "layout"; onClicked: settings.section = "layout" }
                DesktopButton { label: "Health"; chosen: settings.section === "health"; onClicked: { settings.section = "health"; settings.runHealth(); } }
                DesktopButton { label: "How to use"; chosen: settings.section === "help"; onClicked: settings.section = "help" }
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                ColumnLayout {
                    width: parent.width
                    spacing: 14
                    ColumnLayout {
                        visible: settings.section === "layout"
                        Layout.fillWidth: true
                        spacing: 12
                        Text { Layout.fillWidth: true; text: "Edit a draft below, then Save or Cancel. You can also drag fixed-size handles directly on the bar. The clock and workspace/app island stay in place."; wrapMode: Text.WordWrap; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 12 }
                        RowLayout {
                            DesktopButton { label: "Edit layout"; enabled: DesktopState.ready && !DesktopState.editing; onClicked: DesktopState.beginEdit() }
                            DesktopButton { label: "Drag on bar"; enabled: DesktopState.ready; onClicked: { DesktopState.beginEdit(); settings.visible = false; } }
                            DesktopButton { label: "Reset draft"; enabled: DesktopState.editing; onClicked: DesktopState.resetLayout() }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            Repeater {
                                model: ["controls", "status"]
                                ColumnLayout {
                                    id: groupColumn
                                    required property string modelData
                                    readonly property var controlKeys: modelData === "controls" ? DesktopState.controls : DesktopState.status
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 4
                                    Text { text: groupColumn.modelData === "controls" ? "Controls island" : "Status island"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 13; font.bold: true }
                                    Repeater {
                                        model: ScriptModel { values: groupColumn.controlKeys }
                                        RowLayout {
                                            required property string modelData
                                            required property int index
                                            Layout.fillWidth: true
                                            Text { text: DesktopState.controlName(parent.modelData); color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight; Layout.minimumWidth: 60 }
                                            DesktopButton { label: "↑"; enabled: DesktopState.editing && parent.index > 0; Accessible.name: "Move " + parent.modelData + " earlier"; onClicked: DesktopState.shiftControl(parent.modelData, -1) }
                                            DesktopButton { label: "↓"; enabled: DesktopState.editing && parent.index < groupColumn.controlKeys.length - 1; Accessible.name: "Move " + parent.modelData + " later"; onClicked: DesktopState.shiftControl(parent.modelData, 1) }
                                            DesktopButton { label: groupColumn.modelData === "controls" ? "→" : "←"; enabled: DesktopState.editing; Accessible.name: "Move " + parent.modelData + " to other island"; onClicked: DesktopState.moveControl(parent.modelData, groupColumn.modelData === "controls" ? "status" : "controls", "") }
                                        }
                                    }
                                }
                            }
                        }
                        RowLayout {
                            visible: DesktopState.editing
                            DesktopButton { label: "Save"; onClicked: DesktopState.finishEdit(true) }
                            DesktopButton { label: "Cancel"; onClicked: DesktopState.finishEdit(false) }
                        }
                    }
                    ColumnLayout {
                        visible: settings.section === "health"
                        Layout.fillWidth: true
                        spacing: 10
                        RowLayout {
                            Text { text: "Desktop health"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 16; Layout.fillWidth: true }
                            DesktopButton { label: health.running ? "Checking…" : "Check now"; enabled: !health.running; onClicked: settings.runHealth() }
                        }
                        Text { text: "Checks run only when requested. They do not change settings."; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 11 }
                        Repeater {
                            model: settings.checks
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text { text: modelData.status === "ok" ? "✓" : "!"; color: modelData.status === "ok" ? Theme.success : Theme.error; font.pixelSize: 14 }
                                Text { text: modelData.name; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 12; Layout.preferredWidth: 200 }
                                Text { text: modelData.detail; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.Wrap }
                            }
                        }
                        Text { text: settings.message; visible: text.length > 0; color: Theme.error; font.family: Theme.fontMain; font.pixelSize: 11 }
                    }
                    Text {
                        visible: settings.section === "help"
                        Layout.fillWidth: true
                        text: "Calculator: open the app launcher and type = 1920 / 16. Enter copies 120. Searching Calculator also opens it.\n\nWorkspace actions: right-click a workspace indicator. Choose the source window in the menu, then move it or gather the same app there. You stay on the current workspace.\n\nCaffeine: left-click keeps the desktop awake. Right-click toggles Do Not Disturb independently. The small dot means DND is on.\n\nHealth: right-click the settings gear, select Health here, or search Desktop health in the app launcher.\n\nWallpapers: use the bookmark icon to save favorites. Undo restores the previous accepted wallpaper and matching accent."
                        wrapMode: Text.WordWrap
                        color: Theme.text
                        font.family: Theme.fontMain
                        font.pixelSize: 12
                        lineHeight: 1.3
                    }
                }
            }
            Text { Layout.fillWidth: true; visible: DesktopState.error !== ""; text: DesktopState.error; color: Theme.error; wrapMode: Text.Wrap; font.family: Theme.fontMain; font.pixelSize: 11 }
        }
    }
}
