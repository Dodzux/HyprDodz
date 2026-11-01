import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs

// Volume / mic / display and keyboard brightness OSD — a pill at the bottom centre of the focused monitor that
// shows for 1.5s whenever the default output's or the default mic's level or
// mute changes. The mic pill is the volume pill with a mic icon: same level
// bar, same percentage, same "Mute". It reacts to PipeWire itself, not to key
// presses, so the media keys, the bar's scroll-to-change and pavucontrol all
// show it alike. The PwObjectTracker in shell.qml keeps both nodes bound.
Scope {
    id: osd

    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource

    // The keyboard only reports firmware changes; it never writes RGB or brightness.
    property string kind: "sink"

    property real brightnessLevel: 0
    property bool brightnessPending: false
    property bool brightnessShowPending: false
    property int brightnessTarget: -1
    property int brightnessSent: -1
    readonly property int brightnessPct: Math.round(brightnessLevel * 100)

    // One shared read on startup, keys, or bar hover; no permanent polling.
    function refreshBrightness(showPopup) {
        brightnessShowPending = brightnessShowPending || showPopup;
        if (brightnessRead.running) {
            brightnessPending = true;
        } else {
            brightnessRead.running = true;
        }
    }
    function requestBrightness() { refreshBrightness(true); }
    Component.onCompleted: { refreshBrightness(false); refreshNightLight(); refreshKeyboardBrightness(false); }

    property int keyboardValue: 0
    property int keyboardMaximum: 3
    property bool keyboardEventSeen: false
    property bool keyboardShowPending: false
    readonly property real keyboardLevel: keyboardMaximum > 0 ? keyboardValue / keyboardMaximum : 0

    function updateKeyboardBrightness(value, maximum, showPopup) {
        if (!isFinite(value) || !isFinite(maximum) || maximum <= 0 || value < 0 || value > maximum) return;
        keyboardMaximum = maximum;
        keyboardValue = value;
        if (showPopup) show("keyboard");
    }
    function keyboardSignal(line) {
        // UPower reports the level already changed by the ASUS firmware.
        // Ignore owner announcements and BrightnessChangedWithSource duplicates.
        var match = /\.BrightnessChanged \(\s*(?:int32 )?([0-9]+),?\s*\)/.exec(line);
        if (!match) return;
        keyboardEventSeen = true;
        updateKeyboardBrightness(Number(match[1]), keyboardMaximum, true);
    }
    function refreshKeyboardBrightness(showPopup) {
        keyboardShowPending = keyboardShowPending || showPopup;
        if (!keyboardRead.running) keyboardRead.running = true;
    }
    Process {
        id: keyboardRead
        command: ["brightnessctl", "-d", "asus::kbd_backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var fields = this.text.trim().split(",");
                if (fields.length !== 5 || fields[0] !== "asus::kbd_backlight" || fields[1] !== "leds") return;
                // A hardware signal is fresher than the startup snapshot.
                if (!osd.keyboardEventSeen || osd.keyboardShowPending)
                    osd.updateKeyboardBrightness(Number(fields[2]), Number(fields[4]), osd.keyboardShowPending);
                osd.keyboardShowPending = false;
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) console.warn("Keyboard brightness read failed:", exitCode);
            osd.keyboardShowPending = false;
        }
    }
    // One idle D-Bus subscription in the existing shell; no polling or new service.
    Process {
        id: keyboardMonitor
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.UPower",
                  "--object-path", "/org/freedesktop/UPower/KbdBacklight"]
        stdout: SplitParser { onRead: data => osd.keyboardSignal(data) }
        onExited: exitCode => {
            if (exitCode !== 0) console.warn("Keyboard brightness monitor exited:", exitCode);
            keyboardRetry.restart();
        }
    }
    Timer {
        id: keyboardRetry
        interval: 5000
        onTriggered: keyboardMonitor.running = true
    }

    property bool nightLightOn: false
    property bool extraDimOn: false
    property bool nightLightBusy: false
    property string nightLightError: ""
    property string displayAction: "status"
    readonly property string displayHelper: Quickshell.env("HOME") + "/.config/quickshell/scripts/display_modes.py"
    function refreshNightLight() { runDisplay("status"); }
    function toggleNightLight() { runDisplay("night-light"); }
    function toggleExtraDim() { runDisplay("extra-dim"); }
    function runDisplay(action) {
        if (nightLightBusy) return;
        nightLightBusy = true;
        nightLightError = "";
        displayAction = action;
        displayChange.command = ["python3", displayHelper, action];
        displayChange.running = true;
    }
    Process {
        id: displayChange
        stdout: StdioCollector { id: displayOutput }
        stderr: StdioCollector { id: displayErrors }
        onExited: exitCode => {
            osd.nightLightBusy = false;
            try {
                if (exitCode !== 0) throw new Error(displayErrors.text.trim() || "Display mode change failed");
                var state = JSON.parse(displayOutput.text);
                if (typeof state.nightLight !== "boolean" || typeof state.extraDim !== "boolean")
                    throw new Error("Invalid display state");
                osd.nightLightOn = state.nightLight;
                osd.extraDimOn = state.extraDim;
                if (osd.displayAction !== "status") osd.show(osd.displayAction);
            } catch (error) {
                osd.nightLightError = String(error.message || error);
                console.warn("Display modes:", osd.nightLightError);
            }
        }
    }

    function setBrightness(percent) {
        if (!isFinite(percent)) return;
        brightnessTarget = Math.max(1, Math.min(100, Math.round(percent)));
        brightnessLevel = brightnessTarget / 100;
        show("brightness");
        writeBrightness();
    }
    function adjustBrightness(step) { setBrightness(brightnessPct + step); }
    function writeBrightness() {
        if (brightnessWrite.running || brightnessTarget < 0) return;
        brightnessSent = brightnessTarget;
        brightnessWrite.command = ["brightnessctl", "-c", "backlight", "-n1", "set", brightnessSent + "%"];
        brightnessWrite.running = true;
    }

    Process {
        id: brightnessWrite
        onExited: (exitCode) => {
            if (exitCode !== 0) console.warn("Brightness update failed:", exitCode);
            if (osd.brightnessTarget !== osd.brightnessSent) Qt.callLater(osd.writeBrightness);
            else {
                osd.brightnessTarget = -1;
                osd.requestBrightness();
            }
        }
    }

    IpcHandler {
        target: "brightness"
        function showBrightness(): void { osd.requestBrightness(); }
        function showKeyboardBrightness(): void { osd.refreshKeyboardBrightness(true); }
        function keyboardStatus(): string { return JSON.stringify({value: osd.keyboardValue, maximum: osd.keyboardMaximum, percent: Math.round(osd.keyboardLevel * 100), monitoring: keyboardMonitor.running, visible: osdWindow.visible && osd.kind === "keyboard"}); }
        function toggleNightLight(): void { osd.toggleNightLight(); }
        function toggleExtraDim(): void { osd.toggleExtraDim(); }
        function displayStatus(): string { return JSON.stringify({busy: osd.nightLightBusy, nightLight: osd.nightLightOn, extraDim: osd.extraDimOn, error: osd.nightLightError}); }
        function nightLightStatus(): string { return osd.nightLightBusy ? "busy" : osd.nightLightOn ? "on:5500" : "off"; }
        function status(): string { return osd.kind + ":" + Math.round(osd.brightnessLevel * 100) + ":" + osdWindow.visible; }
    }

    Process {
        id: brightnessRead
        command: ["brightnessctl", "-c", "backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var fields = this.text.trim().split(",");
                var percentage = Number((fields[3] || "").replace("%", ""));
                if (fields[1] !== "backlight" || !/%$/.test(fields[3] || "") || !isFinite(percentage)) return;
                if (osd.brightnessTarget < 0)
                    osd.brightnessLevel = Math.max(0, Math.min(100, percentage)) / 100;
                if (osd.brightnessShowPending) osd.show("brightness");
                osd.brightnessShowPending = false;
            }
        }
        onExited: {
            if (osd.brightnessPending) {
                osd.brightnessPending = false;
                Qt.callLater(() => osd.refreshBrightness(false));
            }
        }
    }

    // Node properties settle during the first moments after startup (and after
    // a default-device switch), which would otherwise flash the OSD with no
    // one touching anything.
    property bool armed: false
    Timer { id: armTimer; interval: 1000; running: true; onTriggered: osd.armed = true }
    onSinkChanged: { armed = false; armTimer.restart(); }
    onSourceChanged: { armed = false; armTimer.restart(); }

    function show(which) {
        if (!armed && which !== "brightness" && which !== "keyboard" && which !== "night-light" && which !== "extra-dim") return;
        kind = which;
        var scr = root.getFocusedScreen();
        if (scr) osdWindow.screen = scr;
        osdWindow.visible = true;
        hideTimer.restart();
    }

    Connections {
        target: osd.sink && osd.sink.audio ? osd.sink.audio : null
        function onVolumeChanged() { osd.show("sink"); }
        function onMutedChanged() { osd.show("sink"); }
    }

    Connections {
        target: osd.source && osd.source.audio ? osd.source.audio : null
        function onVolumeChanged() { osd.show("source"); }
        function onMutedChanged() { osd.show("source"); }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osdWindow.visible = false
    }

    PanelWindow {
        id: osdWindow
        visible: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: 0
        color: "transparent"

        anchors.bottom: true
        margins.bottom: 90
        implicitWidth: 280
        implicitHeight: 52

        // Never intercept the pointer — it sits over whatever is below.
        mask: Region {}

        readonly property var node: (osd.kind === "keyboard" || osd.kind === "brightness" || osd.kind === "night-light" || osd.kind === "extra-dim") ? null : (osd.kind === "sink" ? osd.sink : osd.source)
        readonly property bool muted: node && node.audio ? node.audio.muted : false
        readonly property real level: osd.kind === "keyboard" ? osd.keyboardLevel : osd.kind === "extra-dim" ? (osd.extraDimOn ? 0.75 : 1) : osd.kind === "night-light" ? (osd.nightLightOn ? 1 : 0) : osd.kind === "brightness" ? osd.brightnessLevel : (node && node.audio ? Math.min(1, node.audio.volume) : 0)

        Rectangle {
            anchors.fill: parent
            color: Theme.glassBg
            border.color: Theme.glassBorder
            border.width: 1
            radius: height / 2
            antialiasing: true

            Row {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    text: {
                        if (osd.kind === "extra-dim") return "󰃝";
                        if (osd.kind === "night-light") return osd.nightLightOn ? "" : "󰃠";
                        if (osd.kind === "keyboard") return "󰌌";
                        if (osd.kind === "brightness") return "󰃠";
                        if (osd.kind === "source") return osdWindow.muted || osdWindow.level === 0 ? "󰍭" : "󰍬";
                        if (osdWindow.muted || osdWindow.level === 0) return "󰖁";
                        return osdWindow.level >= 0.5 ? "󰕾" : "󰖀";
                    }
                    color: osdWindow.muted ? Theme.subtext0 : Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 18
                }

                // Shared level bar for output, mic, display, and keyboard brightness.
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 22 - valueLabel.width - parent.spacing * 2
                    height: 6
                    radius: 3
                    color: Theme.hoverBg

                    Rectangle {
                        width: parent.width * (osdWindow.muted ? 0 : osdWindow.level)
                        height: parent.height
                        radius: parent.radius
                        color: osdWindow.muted ? Theme.subtext0 : Theme.accent
                        Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    id: valueLabel
                    width: (osd.kind === "night-light" || osd.kind === "extra-dim") ? 116 : 44
                    horizontalAlignment: Text.AlignRight
                    text: osd.kind === "extra-dim" ? (osd.extraDimOn ? "Extra Dim on" : "Extra Dim off") : osd.kind === "night-light" ? (osd.nightLightOn ? "Night · 5500 K" : "Night Light off") : osdWindow.muted ? "Mute" : Math.round(osdWindow.level * 100) + "%"
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
