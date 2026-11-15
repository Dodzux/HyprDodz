pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: self
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool isEnabled: adapter ? (powerKnown ? confirmedEnabled : adapter.enabled) : false
    readonly property var _connected: {
        var devices = Bluetooth.devices;
        return devices ? devices.values.find(d => d.connected) : null;
    }
    readonly property bool isConnected: !!_connected
    readonly property string connectedDevice: _connected ? (_connected.name || _connected.deviceName || "") : ""

    property bool powerKnown: false
    property bool confirmedEnabled: false
    property bool readPending: false
    property string operationPath: ""
    property string queryPath: ""
    property string powerError: ""
    property int writeAttempts: 0
    property bool stateReady: false
    property bool savedEnabled: false
    property bool restoring: false
    property bool targetEnabled: false
    PersistentProperties {
        id: session
        reloadableId: "bluetooth-power-restore"
        property bool restored: false
    }
    FileView {
        id: savedState
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/hypr/bluetooth-power"
        printErrors: false
        atomicWrites: true
        onLoaded: { self.savedEnabled = text().trim() === "on"; self.stateReady = true; restoreDelay.restart(); }
        onLoadFailed: { self.savedEnabled = false; self.stateReady = true; restoreDelay.restart(); }
        onSaveFailed: console.warn("Could not save Bluetooth power preference")
    }
    Timer { id: restoreDelay; interval: 250; onTriggered: self.restore() }
    Timer {
        id: restoreTimeout
        interval: 4000
        onTriggered: {
            self.failed("Bluetooth power change timed out");
        }
    }
    onAdapterChanged: {
        powerKnown = false;
        session.restored = false;
        if (adapter) restoreDelay.restart();
    }
    function restore() {
        if (!stateReady || !adapter || restoring) return;
        if (!session.restored) setPower(savedEnabled);
        else persist();
    }
    function saveConfirmed(enabled) {
        savedEnabled = enabled;
        savedState.setText(enabled ? "on\n" : "off\n");
    }
    function persist() {
        if (!stateReady || !session.restored || restoring || !adapter) return;
        // Qt may still have an initial/stale value. Confirm BlueZ before saving.
        verifyPower();
    }
    function setPower(enabled) {
        if (!adapter || restoring) return;
        targetEnabled = enabled;
        operationPath = adapter.dbusPath;
        writeAttempts = 0;
        powerError = "";
        restoring = true;
        restoreTimeout.restart();
        if (enabled && adapter.state === BluetoothAdapterState.Blocked) unblock.running = true;
        else writePower();
    }
    function writePower() {
        if (!adapter || !restoring || powerWrite.running) return;
        writeAttempts++;
        // Force the BlueZ write even when Qt's cached enabled value is false.
        powerWrite.command = ["busctl", "--system", "--timeout=2s", "set-property", "org.bluez", operationPath,
                              "org.bluez.Adapter1", "Powered", "b", targetEnabled ? "true" : "false"];
        powerWrite.running = true;
    }
    function verifyPower() {
        if (!adapter) return;
        if (powerRead.running) { readPending = true; return; }
        queryPath = adapter.dbusPath;
        powerRead.command = ["busctl", "--system", "--timeout=2s", "get-property", "org.bluez", queryPath,
                             "org.bluez.Adapter1", "Powered"];
        powerRead.running = true;
    }
    function failed(message) {
        powerError = message;
        restoring = false;
        restoreTimeout.stop();
        console.warn(message + "; saved Bluetooth preference retained");
    }
    function observe() {
        if (!adapter || !stateReady) return;
        if (!session.restored && !restoring) restoreDelay.restart();
        else if (!restoring) observeDelay.restart();
    }
    Timer { id: observeDelay; interval: 80; onTriggered: self.persist() }
    Timer { id: writeRetry; interval: 250; onTriggered: self.writePower() }
    Process {
        id: powerWrite
        stderr: StdioCollector { id: writeErrors }
        onExited: exitCode => {
            if (!self.restoring) return;
            if (exitCode !== 0) {
                if (self.writeAttempts < 3) writeRetry.restart();
                else self.failed("Bluetooth power restore failed: " + writeErrors.text.trim());
            } else self.verifyPower();
        }
    }
    Process {
        id: powerRead
        stdout: StdioCollector { id: readOutput }
        stderr: StdioCollector { id: readErrors }
        onExited: exitCode => {
            if (!self.adapter || self.queryPath !== self.adapter.dbusPath) { Qt.callLater(self.restore); return; }
            var match = /^b (true|false)$/.exec(readOutput.text.trim());
            if (exitCode !== 0 || !match) {
                self.failed("Bluetooth power verification failed: " + readErrors.text.trim());
                return;
            }
            var enabled = match[1] === "true";
            self.confirmedEnabled = enabled;
            self.powerKnown = true;
            if (self.restoring) {
                if (enabled === self.targetEnabled) {
                    self.restoring = false;
                    restoreTimeout.stop();
                    session.restored = true;
                    self.saveConfirmed(enabled);
                } else if (self.writeAttempts < 3) writeRetry.restart();
                else self.failed("Bluetooth power did not reach the requested state");
            } else if (session.restored) self.saveConfirmed(enabled);
            if (self.readPending) { self.readPending = false; Qt.callLater(self.verifyPower); }
        }
    }
    Process {
        id: unblock
        command: ["rfkill", "unblock", "bluetooth"]
        onExited: exitCode => {
            if (exitCode !== 0) {
                self.failed("Could not unblock the Bluetooth radio");
            } else self.writePower();
        }
    }
    Connections {
        target: self.adapter
        function onStateChanged() { self.observe(); }
        function onEnabledChanged() { self.observe(); }
    }
    function toggle() { if (adapter && !restoring) setPower(!isEnabled); }
    IpcHandler {
        target: "bluetooth"
        function togglePower(): void { self.toggle(); }
        function powerStatus(): string { return JSON.stringify({enabled: self.isEnabled, saved: self.savedEnabled, ready: self.stateReady, restoring: self.restoring, verified: self.powerKnown, error: self.powerError}); }
    }
}
