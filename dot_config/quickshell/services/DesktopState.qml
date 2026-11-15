pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: state
    readonly property var controls: ["stats", "network", "bluetooth", "audio", "mic", "brightness", "battery"]
    readonly property var status: ["language", "notifications", "shortcuts", "tray", "power"]
    property var labels: ({})
    property var plannerItems: []
    property string plannerFocus: ""
    property string plannerNotes: ""
    property string plannerNext: ""
    property string plannerLater: ""
    property bool ready: false
    property string error: ""
    readonly property var tasks: plannerItems.filter(item => syncedText(item.text) !== null).map(item => ({id:item.id,text:syncedText(item.text),done:item.done}))
    readonly property int remaining: tasks.filter(t => !t.done).length
    PersistentProperties {
        id: presentationState
        reloadableId: "desktop-presentation"
        property bool caffeine: false
    }
    property alias caffeine: presentationState.caffeine
    function syncedText(line) {
        var match=/^\s*@\s*(.*?)\s*@\s*$/.exec(String(line));
        if(!match || !match[1].trim())return null;
        return match[1].trim().slice(0,200);
    }
    function newId() {return Date.now().toString(36)+"-"+Math.random().toString(36).slice(2);}
    function read(content) {
        try {
            var data=JSON.parse(content);
            if(data.version!==1 || !Array.isArray(data.tasks) || !data.labels || typeof data.labels!=="object" || Array.isArray(data.labels))throw new Error("Invalid format");
            var seen=Object.create(null),legacy=[];
            data.tasks.forEach(t=>{
                if(!t || typeof t.id!=="string" || !t.id || seen[t.id] || typeof t.text!=="string" || typeof t.done!=="boolean")throw new Error("Invalid task");
                seen[t.id]=true;legacy.push({id:t.id,text:t.text.slice(0,200),done:t.done});
            });
            var items=[],focus="",notes="",nextText="",laterText="",migrated=!Object.prototype.hasOwnProperty.call(data,"planner");
            if(migrated)items=legacy.map(t=>({id:t.id,text:"@ "+t.text+" @",done:t.done}));
            else {
                var p=data.planner;
                if(!p || !Array.isArray(p.items) || p.items.length>1000 || typeof p.focus!=="string" || typeof p.notes!=="string")throw new Error("Invalid planner");
                seen=Object.create(null);
                p.items.forEach(item=>{
                    if(!item || typeof item.id!=="string" || !item.id || seen[item.id] || typeof item.text!=="string" || /[\r\n]/.test(item.text) || typeof item.done!=="boolean")throw new Error("Invalid planner item");
                    seen[item.id]=true;items.push({id:item.id,text:item.text.slice(0,204),done:item.done});
                });
                focus=p.focus.slice(0,4000);notes=p.notes.slice(0,20000);
                if(p.columns!==undefined){
                    if(!Array.isArray(p.columns) || p.columns.length!==3 || p.columns.some(value=>typeof value!=="string"))throw new Error("Invalid planner columns");
                    focus=p.columns[0].slice(0,4000);nextText=p.columns[1].slice(0,4000);laterText=p.columns[2].slice(0,4000);
                }
            }
            var names={};
            Object.keys(data.labels).forEach(id=>{if(/^[1-9][0-9]?$/.test(id) && typeof data.labels[id]==="string")names[id]=data.labels[id].slice(0,24);});
            plannerItems=items;plannerFocus=focus;plannerNotes=notes;plannerNext=nextText;plannerLater=laterText;labels=names;error="";ready=true;
            if(migrated)Qt.callLater(state.save);
        } catch(e) {error="Could not read saved tasks or planner. The original file has been preserved.";ready=false;}
    }
    function save() {
        if(!ready)return;
        storage.setText(JSON.stringify({version:1,tasks:tasks,labels:labels,planner:{items:plannerItems,focus:plannerFocus,notes:plannerNotes,columns:[plannerFocus,plannerNext,plannerLater]}},null,2)+"\n");
    }
    function addTask(text) {
        text=String(text).trim().slice(0,200);
        if(!ready || !text || tasks.length>=500 || plannerItems.length>=1000)return false;
        plannerItems=plannerItems.concat([{id:newId(),text:"@ "+text+" @",done:false}]);save();return true;
    }
    function updateTask(id,text) {
        text=String(text).trim().slice(0,200);
        var task=tasks.find(t=>t.id===id);
        if(!ready || !text || !task)return false;
        if(task.text===text)return true;
        plannerItems=plannerItems.map(item=>item.id===id?{id:item.id,text:"@ "+text+" @",done:item.done}:item);save();return true;
    }
    function reorderTasks(ids) {
        if(!ready || !Array.isArray(ids) || ids.length!==tasks.length)return false;
        var byId=Object.create(null),seen=Object.create(null);
        plannerItems.forEach(item=>{if(syncedText(item.text)!==null)byId[item.id]=item;});
        for(var i=0;i<ids.length;i++){if(typeof ids[i]!=="string" || !byId[ids[i]] || seen[ids[i]])return false;seen[ids[i]]=true;}
        if(ids.every((id,index)=>tasks[index].id===id))return true;
        var next=0;
        plannerItems=plannerItems.map(item=>syncedText(item.text)!==null?byId[ids[next++]]:item);save();return true;
    }
    function reorderPlannerItems(ids) {
        if(!ready || !Array.isArray(ids) || ids.length!==plannerItems.length)return false;
        var byId=Object.create(null),seen=Object.create(null);
        plannerItems.forEach(item=>byId[item.id]=item);
        for(var i=0;i<ids.length;i++){
            if(typeof ids[i]!=="string" || !byId[ids[i]] || seen[ids[i]])return false;
            seen[ids[i]]=true;
        }
        if(ids.every((id,index)=>plannerItems[index].id===id))return true;
        plannerItems=ids.map(id=>byId[id]);save();return true;
    }
    function toggleTask(id) {
        if(!ready || !plannerItems.some(item=>item.id===id))return;
        plannerItems=plannerItems.map(item=>item.id===id?{id:item.id,text:item.text,done:!item.done}:item);save();
    }
    function removeTask(id) {
        if(!ready)return;
        // Removing from the mini list keeps the planner task, without its sync markers.
        var task=tasks.find(t=>t.id===id);if(!task)return;
        plannerItems=plannerItems.map(item=>item.id===id?{id:item.id,text:task.text,done:item.done}:item);save();
    }
    function addPlannerItem(afterId) {
        if(!ready || plannerItems.length>=1000)return "";
        var item={id:newId(),text:"",done:false};
        var at=plannerItems.findIndex(t=>t.id===afterId),next=plannerItems.slice();
        next.splice(at<0?next.length:at+1,0,item);plannerItems=next;save();return item.id;
    }
    function setPlannerItemText(id,text) {
        if(!ready)return false;
        var at=plannerItems.findIndex(item=>item.id===id);if(at<0)return false;
        var lines=String(text).replace(/\r\n?/g,"\n").split("\n");
        if(plannerItems.length+lines.length-1>1000)return false;
        if(lines.length===1 && plannerItems[at].text===lines[0].slice(0,204))return true;
        var old=plannerItems[at],replacement=lines.map((line,index)=>({id:index?newId():old.id,text:line.slice(0,204),done:index?false:old.done}));
        var next=plannerItems.slice();next.splice(at,1,...replacement);plannerItems=next;save();return true;
    }
    function removePlannerItem(id) {
        if(!ready || !plannerItems.some(item=>item.id===id))return;
        plannerItems=plannerItems.filter(item=>item.id!==id);save();
    }
    function setPlannerFocus(text) {
        text=String(text).slice(0,4000);if(!ready || text===plannerFocus)return;
        plannerFocus=text;save();
    }
    function setPlannerColumn(index,text) {
        if(!ready || !Number.isInteger(index) || index<0 || index>2)return;
        text=String(text).slice(0,4000);
        if(index===0){setPlannerFocus(text);return;}
        if(index===1){if(text===plannerNext)return;plannerNext=text;}
        else{if(text===plannerLater)return;plannerLater=text;}
        save();
    }
    function setPlannerNotes(text) {
        text=String(text).slice(0,20000);if(!ready || text===plannerNotes)return;
        plannerNotes=text;save();
    }
    function renameWorkspace(id,text) {
        if(!ready || !Number.isInteger(id) || id<1 || id>99)return false;
        var next=Object.assign({},labels);
        text=String(text).replace(/[\x00-\x1f\x7f]/g,"").trim().slice(0,24);
        if(text)next[String(id)]=text;else delete next[String(id)];
        labels=next;save();return true;
    }
    FileView {
        id:storage
        path:(Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME")+"/.local/state")+"/hypr/desktop-items.json"
        printErrors:false;atomicWrites:true
        onLoaded:state.read(text())
        onLoadFailed:error=>{
            if(error===FileViewError.FileNotFound){state.plannerItems=[];state.labels={};state.ready=true;}
            else{state.error="Cannot access saved tasks or planner.";state.ready=false;}
        }
        onSaveFailed:{state.error="Could not save changes.";state.ready=false;}
    }
}
