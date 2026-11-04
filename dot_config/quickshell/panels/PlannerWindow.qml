pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Controls
import Quickshell
import qs
import qs.services

FloatingWindow {
    id:planner
    visible:false;title:"Planner"
    implicitWidth:1240;implicitHeight:840;minimumSize:Qt.size(650,480)
    color:Theme.base
    property bool loading:false
    property bool fieldsLoaded:false
    property date openedDate:new Date()
    readonly property real paletteHue:Theme.accent.hslSaturation>.12?Theme.accent.hslHue:.59
    readonly property real paletteSaturation:Math.max(.28,Math.min(.52,Theme.accent.hslSaturation))
    readonly property var inks:[Qt.hsla(paletteHue,paletteSaturation,.77),Qt.hsla((paletteHue+.09)%1,paletteSaturation*.85,.78),Qt.hsla((paletteHue+.91)%1,paletteSaturation*.9,.74)]
    function columnText(index){return index===0?DesktopState.plannerFocus:index===1?DesktopState.plannerNext:DesktopState.plannerLater;}
    function refreshColumn(index){
        var item=columns.itemAt(index);
        if(item && !item.editorActive && !fieldsSave.running){loading=true;item.text=columnText(index);loading=false;}
    }
    function open(scr) {
        if(scr && !visible)screen=scr;
        loading=true;openedDate=new Date();
        for(var i=0;i<3;i++){var item=columns.itemAt(i);if(item)item.text=columnText(i);}
        notesEdit.text=DesktopState.plannerNotes;loading=false;fieldsLoaded=true;
        if(DesktopState.ready && DesktopState.plannerItems.length===0)DesktopState.addPlannerItem("");
        visible=true;Qt.callLater(()=>{var window=surface.Window.window;if(window)window.requestActivate();});
    }
    function saveFields(){
        if(!fieldsLoaded)return;
        for(var i=0;i<3;i++){var item=columns.itemAt(i);if(item)DesktopState.setPlannerColumn(i,item.text);}
        DesktopState.setPlannerNotes(notesEdit.text);
    }
    function flush(){
        fieldsSave.stop();saveFields();
        for(var i=0;i<rows.count;i++){var item=rows.itemAtIndex(i);if(item)item.flush();}
    }
    function focusRow(id){
        var index=DesktopState.plannerItems.findIndex(item=>item.id===id);if(index<0)return;
        rows.forceLayout();rows.positionViewAtIndex(index,ListView.Contain);rows.forceLayout();
        var item=rows.itemAtIndex(index);if(item)item.focusEditor();
    }
    function newRow(afterId){var id=DesktopState.addPlannerItem(afterId);if(id)Qt.callLater(()=>planner.focusRow(id));}
    onVisibleChanged:if(!visible){rows.finishDrag(false);flush();}
    onClosed:visible=false
    Component.onDestruction:flush()
    Shortcut {
        sequence:"Escape";context:Qt.WindowShortcut;enabled:planner.visible && rows.dragId!==""
        onActivated:rows.finishDrag(false)
    }
    Timer {id:fieldsSave;interval:250;onTriggered:planner.saveFields()}
    Connections {
        target:DesktopState
        function onPlannerFocusChanged(){planner.refreshColumn(0);}
        function onPlannerNextChanged(){planner.refreshColumn(1);}
        function onPlannerLaterChanged(){planner.refreshColumn(2);}
        function onPlannerNotesChanged(){if(!notesEdit.activeFocus && !fieldsSave.running){planner.loading=true;notesEdit.text=DesktopState.plannerNotes;planner.loading=false;}}
    }
    Item {
        id:surface;objectName:"planner-surface";anchors.fill:parent
        Keys.onEscapePressed:{if(rows.dragId)rows.finishDrag(false);else{planner.flush();planner.visible=false;}}
        RowLayout {
            anchors {fill:parent;margins:24}
            spacing:24
            ColumnLayout {
                Layout.fillWidth:true;Layout.fillHeight:true;spacing:18
                RowLayout {
                    Layout.fillWidth:true
                    Text {text:"Planner";color:Theme.text;font.family:Theme.fontMain;font.pixelSize:27;font.bold:true;Layout.fillWidth:true}
                    Text {text:Qt.formatDate(planner.openedDate,"ddd, d MMM");color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:11}
                }
                RowLayout {
                    Layout.fillWidth:true;Layout.fillHeight:true;spacing:0
                    Repeater {
                        id:columns;model:3
                        Item {
                            id:column;required property int index
                            Layout.fillWidth:true;Layout.fillHeight:true
                            property alias text:boardEdit.text
                            readonly property bool editorActive:boardEdit.activeFocus
                            readonly property color ink:planner.inks[index]
                            property int layoutRevision:0
                            function lineOffset(line){var pieces=boardEdit.text.split("\n"),offset=0;for(var i=0;i<line;i++)offset+=pieces[i].length+1;return offset;}
                            Rectangle {visible:column.index>0;anchors {top:parent.top;bottom:parent.bottom;left:parent.left}
width:1;color:Theme.glassBorder}
                            Text {
                                id:columnHeading;anchors {left:parent.left;top:parent.top;leftMargin:column.index?18:0}
                                text:["Today","Next","Later"][column.index];color:column.ink;font.family:Theme.fontMain;font.pixelSize:13;font.bold:true
                            }
                            Flickable {
                                id:boardScroll
                                anchors {top:columnHeading.bottom;bottom:parent.bottom;left:parent.left;right:parent.right;topMargin:18;leftMargin:column.index?18:0;rightMargin:14}
                                clip:true;contentWidth:width;contentHeight:Math.max(height,boardEdit.implicitHeight+8);boundsBehavior:Flickable.StopAtBounds
                                Repeater {
                                    model:boardEdit.text.split("\n").length
                                    Text {
                                        required property int index
                                        x:0;y:{var revision=column.layoutRevision;var body=boardEdit.text;var width=boardEdit.width;return boardEdit.positionToRectangle(column.lineOffset(index)).y-1;}
                                        text:"•";color:column.ink;font.family:Theme.fontMain;font.pixelSize:15
                                    }
                                }
                                TextEdit {
                                    id:boardEdit;objectName:"planner-column-"+column.index
                                    x:18;width:Math.max(1,boardScroll.width-18);enabled:DesktopState.ready
                                    selectByMouse:true;wrapMode:TextEdit.Wrap;textFormat:TextEdit.PlainText
                                    color:column.ink;selectionColor:Theme.accent;selectedTextColor:Theme.onAccent;font.family:Theme.fontMain;font.pixelSize:13
                                    onImplicitHeightChanged:column.layoutRevision++
                                    onWidthChanged:column.layoutRevision++
                                    onTextChanged:if(!planner.loading && planner.fieldsLoaded){if(length>4000)remove(4000,length);fieldsSave.restart();column.layoutRevision++;}
                                    onActiveFocusChanged:if(!activeFocus && planner.fieldsLoaded){fieldsSave.stop();planner.saveFields();}
                                    onCursorRectangleChanged:if(activeFocus){if(cursorRectangle.y<boardScroll.contentY)boardScroll.contentY=cursorRectangle.y;else if(cursorRectangle.y+cursorRectangle.height>boardScroll.contentY+boardScroll.height)boardScroll.contentY=cursorRectangle.y+cursorRectangle.height-boardScroll.height+6;}
                                    Text {text:["One thing at a time…","What's next?","For another day…"][column.index];visible:!boardEdit.text;color:Theme.subtext0;font:boardEdit.font;wrapMode:Text.Wrap;width:parent.width}
                                }
                            }
                        }
                    }
                }
                Rectangle {Layout.fillWidth:true;Layout.preferredHeight:1;color:Theme.glassBorder}
                Text {text:"Mini note";color:planner.inks[2];font.family:Theme.fontMain;font.pixelSize:14;font.bold:true}
                Flickable {
                    id:noteScroll;Layout.fillWidth:true;Layout.preferredHeight:92
                    clip:true;contentWidth:width;contentHeight:Math.max(height,notesEdit.implicitHeight);boundsBehavior:Flickable.StopAtBounds
                    TextEdit {
                        id:notesEdit;objectName:"planner-notes";width:noteScroll.width;enabled:DesktopState.ready
                        selectByMouse:true;wrapMode:TextEdit.Wrap;textFormat:TextEdit.PlainText
                        color:planner.inks[2];selectionColor:Theme.accent;selectedTextColor:Theme.onAccent;font.family:Theme.fontMain;font.pixelSize:13
                        onTextChanged:if(!planner.loading && planner.fieldsLoaded){if(length>20000)remove(20000,length);fieldsSave.restart();}
                        onActiveFocusChanged:if(!activeFocus && planner.fieldsLoaded){fieldsSave.stop();planner.saveFields();}
                        onCursorRectangleChanged:if(activeFocus){if(cursorRectangle.y<noteScroll.contentY)noteScroll.contentY=cursorRectangle.y;else if(cursorRectangle.y+cursorRectangle.height>noteScroll.contentY+noteScroll.height)noteScroll.contentY=cursorRectangle.y+cursorRectangle.height-noteScroll.height+6;}
                        Text {text:"A thought worth keeping…";visible:!notesEdit.text;color:Theme.subtext0;font:notesEdit.font}
                    }
                }
                Text {Layout.fillWidth:true;visible:DesktopState.error!=="";text:DesktopState.error;color:Theme.error;font.family:Theme.fontMain;font.pixelSize:11;wrapMode:Text.Wrap}
            }
            Rectangle {
                Layout.preferredWidth:Math.max(270,Math.min(330,planner.width*.29));Layout.fillHeight:true
                radius:12;color:Qt.rgba(1,1,1,.015);border.color:Theme.glassBorder;border.width:1
                ColumnLayout {
                    anchors {fill:parent;margins:16}
spacing:13
                    RowLayout {
                        Layout.fillWidth:true
                        Text {text:"To-Do";color:Theme.text;font.family:Theme.fontMain;font.pixelSize:21;font.bold:true;Layout.fillWidth:true}
                        DesktopButton {color:"transparent";border.width:0;label:"+";implicitWidth:26;implicitHeight:26;enabled:DesktopState.ready;onClicked:planner.newRow("")}
                    }
                    ListView {
                        id:rows;objectName:"planner-items";Layout.fillWidth:true;Layout.fillHeight:true
                        clip:true;spacing:6;boundsBehavior:Flickable.StopAtBounds
                        property string dragId:""
                        property bool dragSuppressed:false
                        property var dragItems:[]
                        property var rowHeights:({})
                        property real pointerY:0
                        property real grabOffset:0
                        property real liftedHeight:32
                        property string liftedText:""
                        property color liftedInk:Theme.text
                        interactive:dragId===""
                        function startDrag(row,offset){
                            row.flush();
                            dragItems=DesktopState.plannerItems.slice();grabOffset=offset;
                            liftedHeight=row.height;liftedText=row.linked?DesktopState.syncedText(row.modelData.text):row.modelData.text;liftedInk=row.ink;
                            dragId=row.modelData.id;
                        }
                        function moveDrag(y){
                            if(!dragId)return;
                            pointerY=y;
                            var from=dragItems.findIndex(item=>item.id===dragId),to=from,pos=0;
                            var logicalY=y+contentY-originY;
                            for(var i=0;i<dragItems.length;i++){
                                var h=rowHeights[dragItems[i].id] || 32,center=pos+h/2;
                                if(i<from && logicalY<center)to=Math.min(to,i);
                                if(i>from && logicalY>center)to=i;
                                pos+=h+spacing;
                            }
                            if(to!==from){var next=dragItems.slice();next.splice(to,0,next.splice(from,1)[0]);dragItems=next;}
                        }
                        function finishDrag(commit){
                            if(!dragId)return;
                            if(!commit)dragSuppressed=true;
                            if(commit)DesktopState.reorderPlannerItems(dragItems.map(item=>item.id));
                            dragId="";dragItems=[];
                        }
                        Timer {
                            interval:20;repeat:true
                            running:rows.dragId!=="" && (rows.pointerY<28 || rows.pointerY>rows.height-28)
                            onTriggered:{
                                var delta=rows.pointerY<28?-6:6;
                                var next=Math.max(rows.originY,Math.min(rows.originY+Math.max(0,rows.contentHeight-rows.height),rows.contentY+delta));
                                if(next!==rows.contentY){rows.contentY=next;rows.moveDrag(rows.pointerY);}
                            }
                        }
                        model:ScriptModel {values:rows.dragId?rows.dragItems:DesktopState.plannerItems;objectProp:"id"}
                        add:Transition {NumberAnimation {property:"opacity";from:0;to:1;duration:Theme.motionNormal}}
                        remove:Transition {NumberAnimation {property:"opacity";to:0;duration:Theme.motionExit}}
                        displaced:Transition {NumberAnimation {property:"y";duration:Theme.motionNormal;easing.type:Easing.OutCubic}}
                        move:Transition {NumberAnimation {property:"y";duration:Theme.motionNormal;easing.type:Easing.OutCubic}}
                        Controls.ScrollBar.vertical:Controls.ScrollBar {
                            visible:rows.contentHeight>rows.height+1;policy:Controls.ScrollBar.AsNeeded
                            contentItem:Rectangle {implicitWidth:3;implicitHeight:24;radius:2;color:Theme.subtext0;opacity:.45}
                            background:Item {}
                        }
                        delegate:Rectangle {
                            id:row;required property var modelData;required property int index
                            objectName:"planner-row-"+modelData.id
                            property bool initialized:false
                            property bool editing:false
                            readonly property bool linked:DesktopState.syncedText(modelData.text)!==null
                            readonly property color ink:planner.inks[index%3]
                            width:rows.width-5;height:Math.max(32,(editing?editor.implicitHeight:taskText.implicitHeight)+10)
                            radius:6;color:editor.activeFocus?Theme.launcherHoverBg:(rowHover.hovered?Qt.rgba(1,1,1,.025):"transparent")
                            Behavior on color {ColorAnimation {duration:Theme.motionFast}}
                            HoverHandler {id:rowHover}
                            function flush(){if(!initialized)return;saveLine.stop();DesktopState.setPlannerItemText(modelData.id,editor.text);}
                            function focusEditor(){editing=true;Qt.callLater(()=>{editor.forceActiveFocus();editor.cursorPosition=editor.length;});}
                            opacity:rows.dragId===modelData.id?.2:1
                            Behavior on opacity {NumberAnimation {duration:Theme.motionFast}}
                            onHeightChanged:if(modelData)rows.rowHeights[modelData.id]=height
                            Component.onCompleted:{editor.text=modelData.text;initialized=true;rows.rowHeights[modelData.id]=height;}
                            onModelDataChanged:if(initialized && editor.text!==modelData.text && (!editor.activeFocus || !saveLine.running)){
                                var cursor=editor.cursorPosition;editor.text=modelData.text;editor.cursorPosition=Math.min(cursor,editor.length);
                            }
                            Timer {id:saveLine;interval:250;onTriggered:row.flush()}
                            MouseArea {
                                id:rowMouse;anchors.fill:parent;enabled:!row.editing
                                acceptedButtons:Qt.LeftButton | Qt.RightButton;preventStealing:true
                                cursorShape:rows.dragId?Qt.ClosedHandCursor:Qt.OpenHandCursor
                                property point pressPoint:Qt.point(0,0)
                                property real offset:0
                                property bool didDrag:false
                                onPressed:mouse=>{rows.dragSuppressed=false;pressPoint=mapToItem(rows,mouse.x,mouse.y);offset=mouse.y;didDrag=false;row.forceActiveFocus();}
                                onPositionChanged:mouse=>{
                                    if(rows.dragSuppressed || !(pressedButtons & Qt.LeftButton))return;
                                    var point=mapToItem(rows,mouse.x,mouse.y);
                                    if(!rows.dragId && Math.abs(point.y-pressPoint.y)>8){didDrag=true;rows.startDrag(row,offset);}
                                    if(rows.dragId===row.modelData.id)rows.moveDrag(point.y);
                                }
                                onReleased:mouse=>{if(mouse.button===Qt.LeftButton && rows.dragId===row.modelData.id)rows.finishDrag(true);}
                                onCanceled:if(rows.dragId===row.modelData.id)rows.finishDrag(false)
                                onClicked:if(!didDrag)row.focusEditor()
                            }
                            RowLayout {
                                anchors {fill:parent;leftMargin:3;rightMargin:2}
spacing:7
                                Text {
                                    text:"⠿";color:Theme.subtext0;font.pixelSize:12
                                    opacity:rowHover.hovered || rows.dragId===row.modelData.id?.65:0
                                    Layout.preferredWidth:10;Layout.preferredHeight:20
                                    MouseArea {
                                        anchors.fill:parent;preventStealing:true;cursorShape:Qt.OpenHandCursor
                                        property point pressPoint:Qt.point(0,0)
                                        property real offset:0
                                        onPressed:mouse=>{rows.dragSuppressed=false;pressPoint=mapToItem(rows,mouse.x,mouse.y);offset=mapToItem(row,mouse.x,mouse.y).y;row.forceActiveFocus();}
                                        onPositionChanged:mouse=>{
                                            if(rows.dragSuppressed || !(pressedButtons & Qt.LeftButton))return;
                                            var point=mapToItem(rows,mouse.x,mouse.y);
                                            if(!rows.dragId && Math.abs(point.y-pressPoint.y)>8)rows.startDrag(row,offset);
                                            if(rows.dragId===row.modelData.id)rows.moveDrag(point.y);
                                        }
                                        onReleased:if(rows.dragId===row.modelData.id)rows.finishDrag(true)
                                        onCanceled:if(rows.dragId===row.modelData.id)rows.finishDrag(false)
                                    }
                                }
                                Rectangle {
                                    Layout.preferredWidth:15;Layout.preferredHeight:15;radius:4
                                    color:row.modelData.done?row.ink:"transparent";border.color:row.ink;border.width:1
                                    Text {anchors.centerIn:parent;text:row.modelData.done?"✓":"";color:Theme.base;font.pixelSize:11}
                                    TapHandler {onTapped:{row.flush();DesktopState.toggleTask(row.modelData.id);}}
                                    Accessible.role:Accessible.CheckBox;Accessible.name:row.modelData.text;Accessible.checked:row.modelData.done
                                    Accessible.onPressAction:{row.flush();DesktopState.toggleTask(row.modelData.id);}
                                }
                                Item {
                                    Layout.fillWidth:true;Layout.preferredHeight:row.editing?editor.implicitHeight:taskText.implicitHeight
                                    Text {
                                        id:taskText;anchors {left:parent.left;right:parent.right}
visible:!row.editing
                                        text:row.linked?DesktopState.syncedText(row.modelData.text):(row.modelData.text || "Write a task…");textFormat:Text.PlainText
                                        color:row.modelData.done?Qt.rgba(row.ink.r,row.ink.g,row.ink.b,.45):row.ink
                                        font.family:Theme.fontMain;font.pixelSize:12;font.strikeout:row.modelData.done;wrapMode:Text.Wrap
                                    }
                                    TextEdit {
                                        id:editor;objectName:"planner-item-input-"+row.modelData.id
                                        anchors {left:parent.left;right:parent.right}
visible:row.editing;enabled:DesktopState.ready
                                        selectByMouse:true;wrapMode:TextEdit.Wrap;textFormat:TextEdit.PlainText
                                        color:row.ink;selectionColor:Theme.accent;selectedTextColor:Theme.onAccent;font.family:Theme.fontMain;font.pixelSize:12
                                        onTextChanged:if(row.initialized && activeFocus && text!==row.modelData.text)saveLine.restart()
                                        onActiveFocusChanged:if(!activeFocus && row.initialized){row.flush();row.editing=false;}
                                        Keys.onReturnPressed:event=>{row.flush();planner.newRow(row.modelData.id);event.accepted=true;}
                                        Keys.onEnterPressed:event=>{row.flush();planner.newRow(row.modelData.id);event.accepted=true;}
                                    }
                                }
                                Rectangle {Layout.preferredWidth:3;Layout.preferredHeight:3;radius:2;color:row.linked?row.ink:"transparent"}
                                DesktopButton {color:"transparent";border.width:0;label:"×";implicitWidth:21;implicitHeight:23;opacity:rowHover.hovered || editor.activeFocus || activeFocus?1:0;enabled:opacity>0;onClicked:DesktopState.removePlannerItem(row.modelData.id)}
                            }
                        }
                        Rectangle {
                            parent:rows;z:30;visible:rows.dragId!==""
                            x:0;y:Math.max(0,Math.min(rows.height-height,rows.pointerY-rows.grabOffset))
                            width:rows.width-5;height:rows.liftedHeight;radius:6
                            color:Theme.glassBg;border.color:Theme.accent;border.width:1
                            Text {
                                anchors {fill:parent;leftMargin:37;rightMargin:18;topMargin:5;bottomMargin:5}
                                text:rows.liftedText;textFormat:Text.PlainText;color:rows.liftedInk
                                font.family:Theme.fontMain;font.pixelSize:12;wrapMode:Text.Wrap;elide:Text.ElideRight
                            }
                        }
                        Text {anchors.centerIn:parent;visible:rows.count===0;text:"Add a task with +";color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:12}
                    }
                    RowLayout {
                        Layout.fillWidth:true
                        Text {text:"@ Task @ → mini list";color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:9;Layout.fillWidth:true}
                        Text {text:DesktopState.tasks.length+" synced";color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:9}
                    }
                }
            }
        }
    }
}
