import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.panels

PopupWindow {
    id: menu
    property int workspaceId: 1
    property var windows: []
    property string message: ""
    readonly property var selectedWindow: windows[windowPicker.currentIndex] || null
    visible: false
    grabFocus: true
    color: "transparent"
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 28
    anchor.rect.y: anchor.item ? anchor.item.height + 12 : 40
    anchor.gravity: Edges.Bottom
    function open() {
        if (action.running) return;
        message = ""; windows = [];
        nameField.text = DesktopState.labels[String(workspaceId)] || "";
        refresh();
    }
    function refresh() {
        if (action.running) return;
        action.command = ["python3", DesktopState.helper, "workspace", "--request", JSON.stringify({workspace: workspaceId, action: "inspect"})];
        action.running = true;
    }
    function move(kind) {
        if (action.running || !selectedWindow) return;
        action.command = ["python3", DesktopState.helper, "workspace", "--request", JSON.stringify({workspace: workspaceId, action: kind, expectedAddress: selectedWindow.address, expectedPid: selectedWindow.pid, expectedSource: selectedWindow.workspace})];
        action.running = true;
    }
    Process {
        id: action
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text);
                    if (result.ok === false) menu.message = result.message;
                    else if (result.windows !== undefined) {
                        menu.windows = result.windows;
                        windowPicker.currentIndex = menu.windows.length ? 0 : -1;
                        menu.visible = true;
                        Qt.callLater(() => nameField.forceActiveFocus());
                    } else {
                        menu.message = result.message || "Done";
                        if (menu.selectedWindow) {
                            var copy = menu.windows.slice();
                            copy[windowPicker.currentIndex] = Object.assign({}, menu.selectedWindow, {workspace: menu.workspaceId, label: menu.selectedWindow.class + " · " + menu.workspaceId});
                            menu.windows = copy;
                        }
                    }
                } catch (e) { menu.message = "Could not read workspace state"; }
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        Keys.onEscapePressed: menu.visible = false
        radius: 14
        color: Theme.glassBg
        border.color: Theme.glassBorder
        border.width: 1
        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
            spacing: 10
            Text { text: "Send to workspace " + menu.workspaceId; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 15 }
            Text { text: "Choose the source window:"; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 11 }
            ComboBox {
                id: windowPicker
                Layout.fillWidth: true
                model: menu.windows
                textRole: "label"
                font.family: Theme.fontMain
                font.pixelSize: 11
                palette.button: Theme.base
                palette.buttonText: Theme.text
                palette.highlight: Theme.accent
                palette.highlightedText: Theme.onAccent
            }
            DesktopButton { Layout.fillWidth: true; label: "Move selected window here"; enabled: !action.running && menu.selectedWindow !== null; onClicked: menu.move("move") }
            DesktopButton { Layout.fillWidth: true; label: "Gather this app here"; enabled: !action.running && menu.selectedWindow !== null; onClicked: menu.move("gather") }
            DesktopButton { label: "Refresh windows"; enabled: !action.running; onClicked: menu.refresh() }
            Text { Layout.fillWidth: true; text: "Moves the selected window without switching your workspace."; wrapMode: Text.Wrap; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 10 }
            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "Optional label for workspace " + menu.workspaceId
                maximumLength: 24
                color: Theme.text
                selectionColor: Theme.accent
                selectedTextColor: Theme.onAccent
                font.family: Theme.fontMain
                font.pixelSize: 11
                background: Rectangle { color: "transparent"; radius: 6; border.color: Theme.borderMuted }
                Keys.onEscapePressed: menu.visible = false
                onAccepted: { DesktopState.label(menu.workspaceId, text); menu.message = "Workspace label saved"; }
            }
            DesktopButton { label: "Save label"; onClicked: { DesktopState.label(menu.workspaceId, nameField.text); menu.message = "Workspace label saved"; } }
            Text { Layout.fillWidth: true; visible: menu.message !== ""; text: menu.message; wrapMode: Text.Wrap; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 11 }
        }
    }
}
