pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property var controls: ["stats", "network", "bluetooth", "audio", "mic", "brightness", "battery"]
    readonly property var status: ["language", "notifications", "shortcuts", "tray", "power"]
    readonly property var labels: ({})
    PersistentProperties {
        id: presentationState
        reloadableId: "desktop-presentation"
        property bool caffeine: false
    }
    property alias caffeine: presentationState.caffeine
}
