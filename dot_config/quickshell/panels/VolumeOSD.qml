import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs

// Volume / mic / brightness OSD — a pill at the bottom centre of the focused monitor that
// shows for 1.5s whenever the default output's or the default mic's level or
// mute changes. The mic pill is the volume pill with a mic icon: same level
// bar, same percentage, same "Mute". It reacts to PipeWire itself, not to key
// presses, so the media keys, the bar's scroll-to-change and pavucontrol all
// show it alike. The PwObjectTracker in shell.qml keeps both nodes bound.
Scope {
    id: osd

    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource

    // Which device the pill is describing: sink, source, or brightness.
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
    Component.onCompleted: refreshBrightness(false)

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
        if (!armed && which !== "brightness") return;
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

        readonly property var node: osd.kind === "brightness" ? null : (osd.kind === "sink" ? osd.sink : osd.source)
        readonly property bool muted: node && node.audio ? node.audio.muted : false
        readonly property real level: osd.kind === "brightness" ? osd.brightnessLevel : (node && node.audio ? Math.min(1, node.audio.volume) : 0)

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
                        if (osd.kind === "brightness") return "󰃠";
                        if (osd.kind === "source") return osdWindow.muted || osdWindow.level === 0 ? "󰍭" : "󰍬";
                        if (osdWindow.muted || osdWindow.level === 0) return "󰖁";
                        return osdWindow.level >= 0.5 ? "󰕾" : "󰖀";
                    }
                    color: osdWindow.muted ? Theme.subtext0 : Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 18
                }

                // Shared level bar for output, mic, and brightness.
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 22 - 44 - parent.spacing * 2
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
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: osdWindow.muted ? "Mute" : Math.round(osdWindow.level * 100) + "%"
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
