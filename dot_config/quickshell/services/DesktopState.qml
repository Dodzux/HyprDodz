pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: self
    readonly property var defaultControls: ["stats", "network", "bluetooth", "audio", "mic", "brightness", "battery"]
    readonly property var defaultStatus: ["language", "notifications", "shortcuts", "tray", "settings", "power"]
    property var controls: defaultControls.slice()
    property var status: defaultStatus.slice()
    property var favorites: []
    property var labels: ({})
    property bool ready: false
    property bool editing: false
    property var savedLayout: null
    property string error: ""
    property string pendingSave: ""
    readonly property string helper: Quickshell.shellDir + "/scripts/desktop_extras.py"
    PersistentProperties {
        id: presentationState
        reloadableId: "desktop-presentation"
        property bool caffeine: false
    }
    property alias caffeine: presentationState.caffeine
    function save() {
        if (!ready) return;
        var c = editing && savedLayout ? savedLayout.controls : controls;
        var s = editing && savedLayout ? savedLayout.status : status;
        pendingSave = JSON.stringify({controls: c, status: s, favorites: favorites, labels: labels});
        flush.restart();
    }
    function flushSave() {
        if (!pendingSave || writer.running) return;
        var payload = pendingSave;
        pendingSave = "";
        writer.command = ["python3", helper, "save", "--request", payload];
        writer.running = true;
    }
    Timer { id: flush; interval: 160; onTriggered: self.flushSave() }
    Process {
        id: loader
        command: ["python3", self.helper, "preferences"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    if (data.ok === false) { self.error = data.message; return; }
                    self.controls = data.controls;
                    self.status = data.status;
                    self.favorites = data.favorites;
                    self.labels = data.labels;
                } catch (e) { self.error = "Could not load desktop preferences"; }
                finally { self.ready = true; }
            }
        }
    }
    Process {
        id: writer
        stdout: StdioCollector {
            onStreamFinished: {
                try { var result = JSON.parse(text); self.error = result.ok ? "" : result.message; }
                catch (e) { self.error = "Could not save desktop preferences"; }
            }
        }
        onExited: Qt.callLater(() => self.flushSave())
    }
    function favorite(path) {
        var copy = favorites.slice();
        var index = copy.indexOf(path);
        if (index < 0) copy.push(path); else copy.splice(index, 1);
        favorites = copy;
        save();
    }
    function label(id, name) {
        var copy = Object.assign({}, labels);
        name = String(name).trim().slice(0, 24).replace(/[\x00-\x1f]/g, "");
        if (name) copy[String(id)] = name; else delete copy[String(id)];
        labels = copy;
        save();
    }
    function beginEdit() {
        if (editing || !ready) return;
        savedLayout = {controls: controls.slice(), status: status.slice()};
        editing = true;
    }
    function finishEdit(accept) {
        if (!editing) return;
        if (!accept) { controls = savedLayout.controls; status = savedLayout.status; }
        editing = false;
        savedLayout = null;
        if (accept) save();
    }
    function shiftControl(key, delta) {
        var group = controls.indexOf(key) >= 0 ? "controls" : "status";
        var list = (group === "controls" ? controls : status).slice();
        var index = list.indexOf(key), target = index + delta;
        if (!editing || index < 0 || target < 0 || target >= list.length) return;
        list.splice(index, 1); list.splice(target, 0, key);
        if (group === "controls") controls = list; else status = list;
    }
    function controlName(key) {
        return ({stats:"System stats",network:"Network",bluetooth:"Bluetooth",audio:"Audio",mic:"Microphone",brightness:"Brightness",battery:"Battery / mode",language:"Keyboard language",notifications:"Notifications",shortcuts:"Keybinds",tray:"System tray",settings:"Desktop settings",power:"Power"})[key] || key;
    }
    function resetLayout() { controls = defaultControls.slice(); status = defaultStatus.slice(); }
    function moveControl(key, group, before) {
        if (!editing || (group !== "controls" && group !== "status")) return;
        if (key === before || defaultControls.concat(defaultStatus).indexOf(key) < 0) return;
        var c = controls.filter(k => k !== key), s = status.filter(k => k !== key);
        var dest = group === "controls" ? c : s;
        var at = dest.indexOf(before);
        dest.splice(at < 0 ? dest.length : at, 0, key);
        controls = c; status = s;
    }
}
