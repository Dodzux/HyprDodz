pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.services

// Popup stack, top-right. Lives directly in ShellRoot (not inside Variants).
//
// A popup is only a *view* of a notification: when it times out the card goes
// away but the notification stays tracked, so it is still in the history
// (NotificationCenter). Only the card's close button, an action, or the app
// itself closes the notification for good.
Item {
    id: osdRoot

    required property var notificationServer
    // Arrival times keyed by notification id, owned by shell.qml.
    required property var receivedTimes

    // Notification objects currently shown as popups, newest last.
    property var popups: []

    // Apps that already play their own sound — a second one from us would
    // double up. Matched against appName, case-insensitively.
    readonly property var selfSoundingApps: ["discord", "vesktop", "webcord", "telegramdesktop", "spotify"]

    function removePopup(notification) {
        popups = popups.filter(p => p !== notification);
    }

    function playSound(notification) {
        var hints = notification.hints || {};
        if (hints["suppress-sound"])
            return;
        var app = (notification.appName || "").toLowerCase();
        if (selfSoundingApps.some(a => app.includes(a)))
            return;

        // canberra resolves XDG sound-theme names, so an app's own sound-name
        // hint works as well as a file path.
        var args = ["canberra-gtk-play", "--description=notification"];
        if (hints["sound-file"]) {
            args.push("-f", String(hints["sound-file"]).replace(/^file:\/\//, ""));
        } else {
            var critical = notification.urgency === NotificationUrgency.Critical;
            args.push("-i", hints["sound-name"] || (critical ? "bell" : "message-new-instant"));
        }
        Quickshell.execDetached(args);
    }

    Connections {
        target: osdRoot.notificationServer
        function onNotification(notification) {
            // History is re-emitted on hot reload; keep it out of the popup stack.
            if (notification.lastGeneration) return;
            // shell.qml has already set tracked = true, so the object outlives
            // this handler. Drop the popup the moment the notification closes,
            // whoever closed it (us, the app, or the history panel).
            notification.closed.connect(() => osdRoot.removePopup(notification));

            // Do Not Disturb: the notification is kept in history, silently.
            // Critical ones (low battery, failed backups) still get through.
            var critical = notification.urgency === NotificationUrgency.Critical;
            if (DndService.isEnabled && !critical)
                return;

            osdRoot.playSound(notification);
            osdRoot.popups = osdRoot.popups.concat([notification]);
        }
    }

    // The overlay panel — only as tall as needed
    PanelWindow {
        id: osdPanel
        visible: osdRoot.popups.length > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "notification-osd"
        // Notifications never steal keyboard input
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
        }

        margins.top: 20
        margins.right: 16

        implicitWidth: 360
        implicitHeight: Math.min(osdColumn.implicitHeight, 600)

        color: "transparent"
        exclusiveZone: 0

        Column {
            id: osdColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 10
            move: Transition { NumberAnimation { properties: "x,y"; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }

            Repeater {
                // ScriptModel diffs by object identity, so adding a popup does
                // not rebuild (and re-animate) the ones already on screen.
                model: ScriptModel {
                    values: osdRoot.popups
                }

                NotificationCard {
                    id: popupCard
                    required property var modelData
                    notification: modelData
                    receivedAt: modelData ? osdRoot.receivedTimes[modelData.id] || null : null
                    width: osdColumn.width

                    // Clicking a popup acknowledges it; it stays in history.
                    onActivated: osdRoot.removePopup(modelData)

                    // ▓▒░ EXPIRY — the app's own timeout if it gave one,
                    // otherwise 5s. Critical notifications stay until handled.
                    // Hovering pauses the countdown so a popup never vanishes
                    // while it is being read. expireTimeout is milliseconds
                    // (`notify-send -t 1500` reads back 1500). -1 uses the
                    // default; 0 explicitly requests no expiry.
                    // Updater completion notices are useful to read, but need
                    // not remain on screen until clicked. Keep history intact.
                    readonly property bool isUpdateNotice: modelData !== null && String(modelData.appName || "").trim().toLowerCase() === "cachyos update"
                    readonly property real timeoutMs: isUpdateNotice ? 12000 : (modelData ? modelData.expireTimeout : 0)
                    readonly property bool mayExpire: isUpdateNotice || (timeoutMs !== 0 && !isCritical)
                    property bool fadingOut: false
                    opacity: fadingOut ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Timer {
                        id: fadeFinish
                        interval: 230
                        onTriggered: {
                            if (!popupCard.modelData) return;
                            if (popupCard.modelData.transient && !popupCard.isUpdateNotice)
                                popupCard.modelData.expire();
                            else
                                osdRoot.removePopup(popupCard.modelData);
                        }
                    }
                    function restartExpiry() {
                        if (modelData && mayExpire && !hovered && !fadingOut) expiry.restart();
                    }
                    Connections {
                        target: popupCard.modelData
                        function onSummaryChanged() { popupCard.restartExpiry(); }
                        function onBodyChanged() { popupCard.restartExpiry(); }
                        function onExpireTimeoutChanged() { popupCard.restartExpiry(); }
                    }
                    Timer {
                        id: expiry
                        interval: popupCard.timeoutMs > 0 ? popupCard.timeoutMs : 5000
                        running: popupCard.modelData !== null && popupCard.mayExpire && !popupCard.hovered && !popupCard.fadingOut
                        onTriggered: {
                            if (!popupCard.modelData) return;
                            popupCard.fadingOut = true;
                            fadeFinish.start();
                        }
                    }

                    // Slide in from the right
                    NumberAnimation on x {
                        from: 360
                        to: 0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
