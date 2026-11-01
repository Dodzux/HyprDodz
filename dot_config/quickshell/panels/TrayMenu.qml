pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id:panel;visible:false
    anchors {top:true;bottom:true;left:true;right:true}
    WlrLayershell.layer:WlrLayer.Overlay
    WlrLayershell.namespace:"quickshell-tray-menu"
    WlrLayershell.keyboardFocus:WlrKeyboardFocus.Exclusive
    color:"transparent";exclusiveZone:-1
    property var rootMenu:null
    property var chain:[]
    property string appTitle:""
    property real anchorX:0
    readonly property var entries:(chain.length?chain[chain.length-1].opener:opener).children.values
    onEntriesChanged: if(visible) Qt.callLater(() => {list.currentIndex=first();})
    function open(scr,item,x) {
        if(scr)screen=scr;
        rootMenu=item.menu;chain=[];appTitle=item.title || item.id || "Menu";anchorX=x;visible=true;
        Qt.callLater(()=>{list.currentIndex=first();card.forceActiveFocus();reveal.restart();});
    }
    function first() {return entries.findIndex(e=>!e.isSeparator && e.enabled);}
    function step(delta) {
        if(!entries.length)return;
        for(var i=0,n=list.currentIndex;i<entries.length;i++) {n=(n+delta+entries.length)%entries.length;if(!entries[n].isSeparator && entries[n].enabled){list.currentIndex=n;list.positionViewAtIndex(n,ListView.Contain);return;}}
    }
    function back() {if(chain.length){var old=chain[chain.length-1].opener;chain=chain.slice(0,-1);old.destroy();Qt.callLater(()=>list.currentIndex=first());}}
    function activate(entry) {
        if(!entry || entry.isSeparator || !entry.enabled)return;
        if(entry.hasChildren){var next=submenuFactory.createObject(panel,{menu:entry});chain=chain.concat([{opener:next,title:entry.text}]);Qt.callLater(()=>list.currentIndex=first());}
        else {entry.triggered();visible=false;}
    }
    QsMenuOpener {id:opener;menu:panel.visible?panel.rootMenu:null}
    Component {id:submenuFactory;QsMenuOpener {}}
    onVisibleChanged:if(!visible){for(var i=chain.length-1;i>=0;i--)chain[i].opener.destroy();chain=[];rootMenu=null;}
    MouseArea {anchors.fill:parent;onClicked:panel.visible=false}
    Rectangle {
        id:card
        x:Math.max(14,Math.min(panel.width-width-14,panel.anchorX-width/2));y:71
        width:292;height:Math.min(panel.height-110,54+list.contentHeight)
        radius:16;color:Theme.glassBg;border.color:Theme.glassBorder;border.width:1
        focus:true
        Keys.onEscapePressed:panel.visible=false
        Keys.onUpPressed:panel.step(-1)
        Keys.onDownPressed:panel.step(1)
        Keys.onReturnPressed:panel.activate(panel.entries[list.currentIndex])
        Keys.onSpacePressed:panel.activate(panel.entries[list.currentIndex])
        Keys.onRightPressed:if(panel.entries[list.currentIndex] && panel.entries[list.currentIndex].hasChildren)panel.activate(panel.entries[list.currentIndex])
        Keys.onLeftPressed:panel.back()
        Keys.onPressed: event => { if(event.key===Qt.Key_Backspace){panel.back();event.accepted=true;} }
        MouseArea {anchors.fill:parent}
        ColumnLayout {
            anchors {fill:parent;margins:8}
spacing:6
            RowLayout {
                Layout.fillWidth:true;Layout.preferredHeight:30
                DesktopButton {label:"‹";visible:panel.chain.length>0;onClicked:panel.back()}
                Text {Layout.fillWidth:true;text:panel.chain.length?panel.chain[panel.chain.length-1].title.replace(/&(.)/g,"$1"):panel.appTitle;textFormat:Text.PlainText;color:Theme.subtext0;font.family:Theme.fontMain;font.pixelSize:11;elide:Text.ElideRight}
            }
            ListView {
                id:list;Layout.fillWidth:true;Layout.fillHeight:true;clip:true;spacing:2
                model:ScriptModel {values:panel.entries}
                boundsBehavior:Flickable.StopAtBounds
                delegate:Rectangle {
                    id:row;required property var modelData;required property int index
                    width:list.width;height:modelData.isSeparator?9:34;radius:8
                    color:!modelData.isSeparator && list.currentIndex===index?Theme.launcherSelectionBg:"transparent"
                    border.color:!modelData.isSeparator && list.currentIndex===index?Theme.launcherSelectionBorder:"transparent";border.width:1
                    Behavior on color {ColorAnimation {duration:Theme.motionFast}}
                    Rectangle {anchors.centerIn:parent;width:parent.width-14;height:1;visible:row.modelData.isSeparator;color:Theme.borderMuted}
                    RowLayout {
                        anchors {fill:parent;leftMargin:9;rightMargin:9}
spacing:8
                        visible:!row.modelData.isSeparator;opacity:row.modelData.enabled?1:.4
                        Item {
                            Layout.preferredWidth:18;Layout.preferredHeight:18
                            Image {anchors.fill:parent;source:row.modelData.icon;sourceSize:Qt.size(18,18);visible:row.modelData.icon!==""}
                            Rectangle {anchors.centerIn:parent;width:14;height:14;radius:row.modelData.buttonType===QsMenuButtonType.RadioButton?7:3;visible:row.modelData.buttonType!==QsMenuButtonType.None;color:"transparent";border.color:Theme.subtext0;border.width:1}
                            Text {anchors.centerIn:parent;visible:row.modelData.buttonType!==QsMenuButtonType.None;text:row.modelData.checkState===Qt.Checked?(row.modelData.buttonType===QsMenuButtonType.RadioButton?"●":"✓"):"";color:Theme.accent;font.pixelSize:13}
                        }
                        Text {Layout.fillWidth:true;text:row.modelData.text.replace(/&(.)/g,"$1");textFormat:Text.PlainText;color:Theme.text;font.family:Theme.fontMain;font.pixelSize:12;elide:Text.ElideRight}
                        Text {text:row.modelData.hasChildren?"›":"";color:Theme.subtext0;font.pixelSize:17}
                    }
                    HoverHandler {enabled:!row.modelData.isSeparator && row.modelData.enabled;cursorShape:Qt.PointingHandCursor;onHoveredChanged:if(hovered)list.currentIndex=row.index}
                    TapHandler {enabled:!row.modelData.isSeparator && row.modelData.enabled;onTapped:panel.activate(row.modelData)}
                }
            }
        }
    }
    ParallelAnimation {
        id:reveal
        NumberAnimation {target:card;property:"opacity";from:0;to:1;duration:Theme.motionNormal}
        NumberAnimation {target:card;property:"scale";from:.97;to:1;duration:Theme.motionNormal;easing.type:Easing.OutCubic}
    }
}
