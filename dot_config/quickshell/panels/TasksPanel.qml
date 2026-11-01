pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

PanelWindow {
    id: panel
    visible: false
    anchors { top:true; bottom:true; left:true; right:true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-tasks"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    exclusiveZone: -1
    onVisibleChanged: if (visible) { reveal.restart();Qt.callLater(() => entry.forceActiveFocus()); } else taskList.finishDrag(false)
    MouseArea { anchors.fill:parent;onClicked:panel.visible=false }
    Rectangle {
        id:card;objectName:"tasks-card"
        anchors { top:parent.top; right:parent.right; topMargin:71; rightMargin:16 }
        width:380
        readonly property real chromeHeight: 24 + taskHeader.implicitHeight + taskEntry.implicitHeight + content.spacing * 2 + (saveError.visible ? saveError.implicitHeight + content.spacing : 0)
        readonly property real wantedListHeight: DesktopState.tasks.length ? taskList.contentHeight : 48
        height:Math.min(Math.min(500,Math.max(120,panel.height-87)),chromeHeight+wantedListHeight)
        Behavior on height { enabled:panel.visible;NumberAnimation {duration:Theme.motionNormal;easing.type:Easing.OutCubic} }
        radius:19;color:Theme.glassBg;border.color:Theme.glassBorder;border.width:1
        Keys.onEscapePressed: {if(taskList.dragId)taskList.finishDrag(false);else panel.visible=false;}
        MouseArea { anchors.fill:parent }
        ColumnLayout {
            id:content
            anchors { fill:parent; margins:12 }
spacing:10
            RowLayout {
                id:taskHeader
                Layout.fillWidth:true
                Text { text:"Tasks";color:Theme.text;font.family:Theme.fontMain;font.pixelSize:13;font.bold:true;Layout.fillWidth:true }
                Text { text:DesktopState.remaining+" left";color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:10 }
                DesktopButton {label:"Planner";implicitHeight:26;onClicked:{panel.visible=false;Qt.callLater(()=>root.openPlanner());}}
            }
            RowLayout {
                id:taskEntry
                Layout.fillWidth:true;spacing:6
                Rectangle {
                    Layout.fillWidth:true;Layout.preferredHeight:34
                    radius:8;color:entry.activeFocus?Theme.launcherHoverBg:Theme.glassBg;border.color:entry.activeFocus?Theme.accent:Theme.borderMuted;border.width:1
                    Behavior on color {ColorAnimation {duration:Theme.motionFast}}
                    TextInput {
                        id:entry;objectName:"task-input"
                        anchors { fill:parent; margins:9 }
clip:true
                        color:Theme.text;selectionColor:Theme.accent;selectedTextColor:Theme.onAccent
                        font.family:Theme.fontMain;font.pixelSize:12;selectByMouse:true;maximumLength:200
                        enabled:DesktopState.ready
                        Keys.onEscapePressed: {if(taskList.dragId)taskList.finishDrag(false);else panel.visible=false;}
                        onAccepted:if(DesktopState.addTask(text))text=""
                        Text { text:"Add a task…";visible:!entry.text;color:Theme.subtext0;font:entry.font }
                    }
                }
                DesktopButton { label:"+";enabled:DesktopState.ready && entry.text.trim().length>0;onClicked:if(DesktopState.addTask(entry.text)){entry.text="";entry.forceActiveFocus();} }
            }
            ListView {
                id:taskList;objectName:"tasks-list";Layout.fillWidth:true;Layout.fillHeight:true;clip:true;spacing:6
                boundsBehavior:Flickable.StopAtBounds
                property string dragId:""
                property var dragItems:[]
                property var rowHeights:({})
                property real pointerY:0
                property real grabOffset:0
                property real liftedHeight:44
                property string liftedText:""
                property bool liftedDone:false
                readonly property var displayedTasks:dragId?dragItems:DesktopState.tasks
                interactive:dragId===""
                function startDrag(row,offset) {
                    dragItems=DesktopState.tasks.slice();grabOffset=offset;
                    liftedHeight=row.height;liftedText=row.modelData.text;liftedDone=row.modelData.done;
                    dragId=row.modelData.id;
                }
                function moveDrag(y) {
                    if(!dragId)return;
                    pointerY=y;
                    var from=dragItems.findIndex(t=>t.id===dragId),to=from,pos=0;
                    var logicalY=y+contentY-originY;
                    for(var i=0;i<dragItems.length;i++) {
                        var h=rowHeights[dragItems[i].id] || 44;
                        var center=pos+h/2;
                        if(i<from && logicalY<center)to=Math.min(to,i);
                        if(i>from && logicalY>center)to=i;
                        pos+=h+spacing;
                    }
                    if(to!==from){var next=dragItems.slice();next.splice(to,0,next.splice(from,1)[0]);dragItems=next;}
                }
                function finishDrag(commit) {
                    if(!dragId)return;
                    if(commit)DesktopState.reorderTasks(dragItems.map(t=>t.id));
                    dragId="";dragItems=[];
                }
                Timer {
                    interval:20;repeat:true
                    running:taskList.dragId!=="" && (taskList.pointerY<28 || taskList.pointerY>taskList.height-28)
                    onTriggered:{
                        var delta=taskList.pointerY<28?-6:6;
                        var next=Math.max(taskList.originY,Math.min(taskList.originY+Math.max(0,taskList.contentHeight-taskList.height),taskList.contentY+delta));
                        if(next!==taskList.contentY){taskList.contentY=next;taskList.moveDrag(taskList.pointerY);}
                    }
                }
                model:ScriptModel {values:taskList.displayedTasks;objectProp:"id"}
                add:Transition { NumberAnimation {properties:"opacity";from:0;to:1;duration:Theme.motionNormal} }
                remove:Transition { NumberAnimation {properties:"opacity";to:0;duration:Theme.motionExit} }
                move:Transition { NumberAnimation {properties:"y";duration:Theme.motionNormal;easing.type:Easing.OutCubic} }
                displaced:Transition { NumberAnimation {properties:"y";duration:Theme.motionNormal;easing.type:Easing.OutCubic} }
                delegate:Rectangle {
                    id:row;required property var modelData
                    objectName:"task-row-"+modelData.id
                    property bool editing:false
                    opacity:taskList.dragId===modelData.id ? 0.2 : 1
                    Behavior on opacity {NumberAnimation {duration:Theme.motionFast}}
                    onHeightChanged:if(modelData)taskList.rowHeights[modelData.id]=height
                    Component.onCompleted:taskList.rowHeights[modelData.id]=height
                    function beginEdit() {
                        if(!DesktopState.ready || editing)return;
                        editor.text=modelData.text;editing=true;
                        Qt.callLater(()=>{editor.forceActiveFocus();editor.cursorPosition=editor.length;});
                    }
                    function commitEdit() {
                        if(!editing)return;
                        DesktopState.updateTask(modelData.id,editor.text);
                        editing=false;
                    }
                    function cancelEdit() {editing=false;}
                    width:taskList.width;height:Math.max(44,(editing?editor.implicitHeight:label.implicitHeight)+20)
                    radius:12;color:editing?Theme.launcherSelectionBg:(hover.hovered?Theme.launcherHoverBg:"transparent")
                    border.color:editing?Theme.accent:Theme.glassBorder;border.width:1
                    Behavior on color { ColorAnimation {duration:Theme.motionFast} }
                    HoverHandler {id:hover}
                    MouseArea {
                        anchors.fill:parent;acceptedButtons:Qt.LeftButton | Qt.RightButton;enabled:!row.editing;preventStealing:true
                        cursorShape:taskList.dragId?Qt.ClosedHandCursor:Qt.OpenHandCursor
                        property point pressedPoint:Qt.point(0,0)
                        property real rowOffset:0
                        onPressed:mouse=>{pressedPoint=mapToItem(taskList,mouse.x,mouse.y);rowOffset=mouse.y;if(mouse.button===Qt.LeftButton)row.forceActiveFocus();}
                        onPositionChanged:mouse=>{
                            if(!(pressedButtons & Qt.LeftButton))return;
                            var point=mapToItem(taskList,mouse.x,mouse.y);
                            if(!taskList.dragId && Math.abs(point.y-pressedPoint.y)>8)taskList.startDrag(row,rowOffset);
                            if(taskList.dragId===row.modelData.id)taskList.moveDrag(point.y);
                        }
                        onReleased:mouse=>{if(mouse.button===Qt.LeftButton && taskList.dragId===row.modelData.id)taskList.finishDrag(true);}
                        onCanceled:if(taskList.dragId===row.modelData.id)taskList.finishDrag(false)
                        onClicked:mouse=>{if(mouse.button===Qt.RightButton)row.beginEdit();}
                    }
                    RowLayout {
                        anchors {fill:parent;leftMargin:10;rightMargin:8}
spacing:10
                        Rectangle {
                            Layout.preferredWidth:18;Layout.preferredHeight:18;radius:5
                            color:row.modelData.done?Theme.accent:"transparent";border.color:row.modelData.done?Theme.accent:Theme.subtext0;border.width:1
                            Text {anchors.centerIn:parent;text:row.modelData.done?"✓":"";color:Theme.onAccent;font.pixelSize:12}
                            TapHandler {onTapped:DesktopState.toggleTask(row.modelData.id)}
                            Accessible.role:Accessible.CheckBox;Accessible.name:row.modelData.text;Accessible.checked:row.modelData.done
                            Accessible.onPressAction:DesktopState.toggleTask(row.modelData.id)
                        }
                        Item {
                            Layout.fillWidth:true;Layout.preferredHeight:row.editing?editor.implicitHeight:label.implicitHeight
                            Text {
                                id:label;anchors {left:parent.left;right:parent.right}
                                visible:!row.editing;text:row.modelData.text;textFormat:Text.PlainText
                                color:row.modelData.done?Theme.subtext0:Theme.text;font.family:Theme.fontMain;font.pixelSize:12;font.strikeout:row.modelData.done
                                wrapMode:Text.Wrap;maximumLineCount:4;elide:Text.ElideRight
                            }
                            TextEdit {
                                id:editor;objectName:"task-editor-"+row.modelData.id
                                anchors {left:parent.left;right:parent.right}
                                visible:row.editing;selectByMouse:true;textFormat:TextEdit.PlainText;wrapMode:TextEdit.Wrap
                                color:Theme.text;selectionColor:Theme.accent;selectedTextColor:Theme.onAccent
                                font.family:Theme.fontMain;font.pixelSize:12
                                onTextChanged:if(length>200)remove(200,length)
                                onActiveFocusChanged:if(!activeFocus && row.editing)row.commitEdit()
                                Keys.onReturnPressed:event=>{row.commitEdit();event.accepted=true;}
                                Keys.onEnterPressed:event=>{row.commitEdit();event.accepted=true;}
                                Keys.onEscapePressed:event=>{row.cancelEdit();event.accepted=true;}
                            }
                        }
                        DesktopButton { label:"×";onClicked:DesktopState.removeTask(row.modelData.id) }
                    }
                }
                Rectangle {
                    parent:taskList;z:30;visible:taskList.dragId!==""
                    x:0;y:Math.max(0,Math.min(taskList.height-height,taskList.pointerY-taskList.grabOffset))
                    width:taskList.width;height:taskList.liftedHeight
                    radius:12;color:Theme.launcherSelectionBg;border.color:Theme.accent;border.width:1
                    Rectangle {
                        x:10;anchors.verticalCenter:parent.verticalCenter;width:18;height:18;radius:5
                        color:taskList.liftedDone?Theme.accent:"transparent";border.color:taskList.liftedDone?Theme.accent:Theme.subtext0;border.width:1
                        Text {anchors.centerIn:parent;text:taskList.liftedDone?"✓":"";color:Theme.onAccent;font.pixelSize:12}
                    }
                    Text {
                        anchors {left:parent.left;right:parent.right;verticalCenter:parent.verticalCenter;leftMargin:38;rightMargin:50}
                        text:taskList.liftedText;textFormat:Text.PlainText;color:Theme.text;font.family:Theme.fontMain;font.pixelSize:12
                        font.strikeout:taskList.liftedDone;wrapMode:Text.Wrap;maximumLineCount:4;elide:Text.ElideRight
                    }
                }
                Text {
                    anchors.centerIn:parent;visible:DesktopState.tasks.length===0
                    text:"Nothing to do. Enjoy the quiet.";color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:11
                }
            }
            Text {id:saveError;Layout.fillWidth:true;visible:DesktopState.error!=="";text:DesktopState.error;color:Theme.error;font.pixelSize:11;wrapMode:Text.Wrap}
        }
    }
    ParallelAnimation {
        id:reveal
        NumberAnimation {target:card;property:"opacity";from:0;to:1;duration:Theme.motionNormal}
        NumberAnimation {target:card;property:"scale";from:.97;to:1;duration:Theme.motionNormal;easing.type:Easing.OutCubic}
    }
}
