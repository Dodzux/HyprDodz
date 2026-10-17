pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: self
    PersistentProperties {
        id: saved
        reloadableId: "notification-dnd"
        property bool enabled: false
    }
    property alias isEnabled: saved.enabled
    function toggle() { isEnabled = !isEnabled; }
}
