pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire as Pw

Singleton {
    id: service
    readonly property var sink: Pw.Pipewire.defaultAudioSink
    readonly property bool playback: Pw.Pipewire.linkGroups.values.some(link =>
        link.target === sink && link.source && link.source.isStream && link.source.audio
        && link.state === Pw.PwLinkState.Active)
    // Site selection changes only drawing mode; audio capture and visibility
    // continue to follow their existing lifecycle.
    readonly property string selectedSite: siteMode.appliedSite
    Scope {
        id: siteMode
        property string appliedSite: ""
        readonly property var focusedWindow: ToplevelManager.activeToplevel
        readonly property var windows: ToplevelManager.toplevels.values.filter(w => browser(w.appId)).map(w => ({appId: w.appId, title: w.title}))
        readonly property var snapshot: ({
            focused: focusedWindow ? {appId: focusedWindow.appId, title: focusedWindow.title} : null,
            windows: windows
        })
        readonly property string detectedSite: detect(snapshot)

        function browser(app) {
            return /^(brave|chromium|google-chrome|chrome|firefox|zen)([.\-]|$)/i.test(app || "")
                || /^(youtube[ -]?music|com\.google\.YoutubeMusic)$/i.test(app || "");
        }
        function titleSite(title) {
            var clean = String(title || "").replace(/[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g, "").trim().replace(/^\(\d+\)\s*/, "").replace(/\s+[—–-]\s+(?:Brave(?:\s*(?:[—–|+\-]\s*)?Origin)?|Google Chrome|Chromium|Mozilla Firefox|Firefox|Zen Browser)(?:\s+Browser)?$/i, "");
            if (/(?:^|[—–|\-]\s*)YouTube Music$/i.test(clean)) return "youtube-music";
            if (/(?:^|[—–|\-]\s*)YouTube$/i.test(clean)) return "youtube";
            return "";
        }
        function detect(s) {
            // The selected browser tab always wins, regardless of which player is
            // playing or which site the player metadata describes.
            if (s.focused && browser(s.focused.appId)) return titleSite(s.focused.title);
            // Once chosen, keep that site while the user works in another app.
            // Background media/title updates must never choose another site.
            if (appliedSite) return "";
            var sites = [];
            for (var i = 0; i < s.windows.length; i++) {
                var w = s.windows[i];
                if (!browser(w.appId)) continue;
                var site = titleSite(w.title);
                if (site && !sites.includes(site)) sites.push(site);
            }
            return sites.length === 1 ? sites[0] : "";
        }
        function modeFor(site) { return site === "youtube-music" ? "smooth" : "mirror"; }
        function applyDetected() {
            if (!detectedSite || detectedSite === appliedSite) return;
            var next = detectedSite;
            appliedSite = next;
            service.mirrored = modeFor(next) === "mirror";
        }
        onDetectedSiteChanged: settle.restart()
        Component.onCompleted: settle.restart()
        Timer { id: settle; interval: 250; onTriggered: siteMode.applyDetected() }
    }

    readonly property real sensitivity: 2.2
    property bool paused: false
    property bool mirrored: false
    property bool resuming: false
    readonly property bool wanted: playback && sink && !paused
    Pw.PwObjectTracker {
        objects: Pw.Pipewire.linkGroups.values.filter(link =>
            link.target === service.sink && link.source && link.source.isStream && link.source.audio)
    }
    property var levels: Array(28).fill(0)
    property bool active: false
    property int frames: 0
    property real peak: 0
    property string errorMessage: ""
    property string captureSource: ""
    property string pendingSource: ""
    property bool preparing: false
    property bool starting: false
    property bool stopping: false
    property int retries: 0
    readonly property string configPath: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-cava-" + Quickshell.processId + ".conf"

    onWantedChanged: {
        retries = 0;
        if (wanted) { stopDelay.stop(); resuming = true; warmup.restart(); reconcile(); }
        else { resuming = false; warmup.stop(); stopDelay.restart(); }
    }
    onSinkChanged: { retries = 0; reconcile(); }
    onPlaybackChanged: if (!playback) { silence.stop(); clear(); }
    Component.onCompleted: reconcile()

    onPausedChanged: {
        if (paused) { silence.stop(); clear(); }
        else if (!playback) clear();
    }
    function clear() { levels = Array(28).fill(0); active = false; peak = 0; }
    function reconcile() {
        if (!wanted || !sink || preparing || starting || stopping) return;
        var source = sink.name + ".monitor";
        // Node names are supplied by PipeWire, not shell command strings.
        if (!source || /[\r\n\[\]]/.test(source)) return;
        if (backend.running) {
            if (captureSource !== source) { stopping = true; backend.running = false; }
            return;
        }
        var contents = "[general]\nframerate=30\nbars=28\nautosens=1\nsleep_timer=3\n"
            + "[input]\nmethod=pulse\nsource=" + source + "\n"
            + "[output]\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100\nbar_delimiter=59\nframe_delimiter=10\nchannels=mono\nmono_option=average\n"
            + "[smoothing]\nnoise_reduction=70\n";
        // FileView skips identical writes, so no saved signal would follow.
        if (config.text() === contents) {
            captureSource = source;
            errorMessage = "";
            starting = true;
            backend.running = true;
            return;
        }
        preparing = true;
        pendingSource = source;
        config.setText(contents);
    }
    function parseFrame(line) {
        if (paused) return;
        var fields = line.trim().split(";");
        if (fields[fields.length - 1] === "") fields.pop();
        if (fields.length !== 28) return;
        var next = [], maximum = 0;
        for (var i = 0; i < fields.length; i++) {
            if (!/^\d+$/.test(fields[i])) return;
            var value = Math.max(0, Math.min(1, Number(fields[i]) / 100 * sensitivity));
            next.push(value);
            maximum = Math.max(maximum, value);
        }
        levels = next;
        frames++;
        peak = maximum;
        if (maximum > 0.015) { active = true; resuming = false; warmup.stop(); silence.restart(); }
    }
    FileView {
        id: config
        path: service.configPath
        atomicWrites: true
        printErrors: false
        onSaved: {
            service.preparing = false;
            if (service.wanted && service.sink && service.pendingSource === service.sink.name + ".monitor") {
                service.captureSource = service.pendingSource;
                service.errorMessage = "";
                service.starting = true;
                backend.running = true;
            } else Qt.callLater(service.reconcile);
        }
        onSaveFailed: {
            service.preparing = false;
            service.resuming = false;
            warmup.stop();
            service.errorMessage = "Could not prepare the audio visualizer";
            console.warn(service.errorMessage);
        }
    }
    Timer { id: stopDelay; interval: 550; onTriggered: {
        if (service.wanted) return;
        if (backend.running || service.starting) { service.stopping = true; backend.running = false; }
        service.starting = false;
        service.clear();
    } }
    Timer { id: warmup; interval: 1000; onTriggered: service.resuming = false }
    Timer { id: silence; interval: 180; onTriggered: service.clear() }
    Timer { id: retry; interval: 1800; onTriggered: service.reconcile() }
    Process {
        id: backend
        command: ["cava", "-p", service.configPath]
        onStarted: service.starting = false
        stdout: SplitParser { onRead: line => service.parseFrame(line) }
        stderr: StdioCollector { id: errors }
        onExited: exitCode => {
            service.starting = false;
            service.captureSource = "";
            service.clear();
            var expectedStop = service.stopping;
            service.stopping = false;
            if (exitCode !== 0 && service.wanted && !expectedStop) {
                service.errorMessage = errors.text.trim().slice(-240) || "Audio visualizer stopped";
                console.warn("CAVA:", service.errorMessage);
                if (++service.retries <= 3) retry.restart();
            } else if (service.wanted) Qt.callLater(service.reconcile);
        }
    }
    IpcHandler {
        target: "cava"
        function siteStatus(): string {
            function brief(w) {
                if (!w) return null;
                var title = String(w.title || "");
                return {appId: w.appId, browser: siteMode.browser(w.appId), site: siteMode.titleSite(title),
                    mentionsYouTube: title.includes("YouTube"), mentionsMusic: title.includes("YouTube Music"),
                    afterYouTube: title.includes("YouTube") ? title.split("YouTube").pop().length : -1,
                    braveOrigin: /Brave Origin$/.test(title), braveParentheses: /Brave \(Origin\)$/.test(title),
                    braveHyphen: /Brave [—–-] Origin$/.test(title)};
            }
            return JSON.stringify({focused: brief(siteMode.focusedWindow), detected: siteMode.detectedSite,
                applied: siteMode.appliedSite, windows: siteMode.windows.map(brief)});
        }
        function status(): string { return JSON.stringify({running: backend.running, active: service.active, playback: service.playback, paused: service.paused, resuming: service.resuming, mode: service.mirrored ? "mirror" : "smooth", site: service.selectedSite, sensitivity: service.sensitivity, frames: service.frames, peak: service.peak, source: service.captureSource, error: service.errorMessage}); }
        function togglePaused(): void { service.paused = !service.paused; }
        function setMode(mode: string): void { if (mode === "smooth" || mode === "mirror") service.mirrored = mode === "mirror"; }
    }
}
