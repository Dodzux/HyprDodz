import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

PanelWindow {
    id:panel;visible:false
    property int workspaceId:1
    anchors {top:true;bottom:true;left:true;right:true}
    WlrLayershell.namespace:"quickshell-workspace-name"
    WlrLayershell.layer:WlrLayer.Overlay
    WlrLayershell.keyboardFocus:WlrKeyboardFocus.Exclusive
    color:"transparent";exclusiveZone:-1
    function open(scr,id) {
        if(scr)screen=scr;
        workspaceId=id;entry.text=DesktopState.labels[String(id)] || "";
        visible=true;Qt.callLater(()=>{entry.forceActiveFocus();entry.selectAll();});
    }
    function save() {if(DesktopState.renameWorkspace(workspaceId,entry.text))visible=false;}
    MouseArea {anchors.fill:parent;onClicked:panel.visible=false}
    Rectangle {
        id:card;anchors.centerIn:parent;width:340;height:160;radius:16
        color:Theme.glassBg;border.color:Theme.glassBorder;border.width:1
        MouseArea {anchors.fill:parent}
        ColumnLayout {
            anchors {fill:parent;margins:16}
spacing:12
            Text {text:"Rename workspace "+panel.workspaceId;color:Theme.text;font.family:Theme.fontMain;font.pixelSize:13;font.bold:true}
            Rectangle {
                Layout.fillWidth:true;Layout.preferredHeight:36;radius:8;color:Theme.bgSelection;border.color:Theme.accent;border.width:1
                TextInput {
                    id:entry;anchors {fill:parent;margins:9}
maximumLength:24;selectByMouse:true;clip:true
                    color:Theme.text;selectionColor:Theme.accent;selectedTextColor:Theme.onAccent;font.family:Theme.fontMain;font.pixelSize:12
                    onAccepted:panel.save();Keys.onEscapePressed:panel.visible=false
                    Text {text:"Leave empty to reset";visible:!entry.text;color:Theme.subtext0;font:entry.font}
                }
            }
            RowLayout {
                Layout.fillWidth:true
                Text {text:"";Layout.fillWidth:true}
                DesktopButton {label:"Cancel";onClicked:panel.visible=false}
                DesktopButton {label:"Save";enabled:DesktopState.ready;onClicked:panel.save()}
            }
        }
        opacity:panel.visible?1:0
        Behavior on opacity {NumberAnimation {duration:Theme.motionNormal}}
    }
}
