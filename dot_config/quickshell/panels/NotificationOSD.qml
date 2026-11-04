pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.services

// Popup stack follows the bar edge. Lives directly in ShellRoot (not inside Variants).
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

    function soundCategory(notification) {
        if (notification.urgency === NotificationUrgency.Critical) return "warning";
        var category = String((notification.hints || {})["category"] || "").toLowerCase();
        var app = String(notification.appName || "").toLowerCase();
        // Welcome uses Warm Keys; reserve the old tone for actual system alerts.
        if (category === "system.login") return "messages";
        if (/^(transfer\.complete|job\.complete|complete)/.test(category)) return "complete";
        if (/^device/.test(category)) return "devices";
        if (/^(control|x-hypr\.control)/.test(category) || /fn key|fn mode|performance|brightness|volume/.test(app)) return "controls";
        if (/^system/.test(category) || /hyprland|cachyos|update|system/.test(app)) return "system";
        return "messages";
    }
    function soundCommand(notification) {
        var hints = notification.hints || {};
        if (hints["suppress-sound"]) return [];
        var app = (notification.appName || "").toLowerCase();
        if (selfSoundingApps.some(a => app.includes(a))) return [];
        var args = ["canberra-gtk-play", "--description=notification"];
        if (hints["sound-file"]) args.push("-f", String(hints["sound-file"]).replace(/^file:\/\//, ""));
        else if (hints["sound-name"]) args.push("-i", String(hints["sound-name"]));
        else {
            var category = soundCategory(notification);
            if (category === "warning") args.push("-i", "bell");
            else if (category === "system") args.push("-i", "message-new-instant");
            else args.push("-f", Quickshell.shellDir + "/assets/sounds/warm-" + category + ".wav");
        }
        return args;
    }
    function playSound(notification) {
        if (DndService.isEnabled && notification.urgency !== NotificationUrgency.Critical) return;
        var args = soundCommand(notification);
        // A stalled audio device must not leave notification players running indefinitely.
        if (args.length) Quickshell.execDetached(["timeout", "--signal=TERM", "--kill-after=1s", "3s"].concat(args));
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

        anchors { top: true; left: true }
        margins.top: BarState.notificationY(screen, implicitHeight)
        margins.left: BarState.notificationX(screen, implicitWidth)

        implicitWidth: 360
        implicitHeight: Math.min(osdColumn.implicitHeight, 600)

        color: "transparent"
        exclusiveZone: -1

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
                        function onSummaryChanged() { popupCard.restartExpiry(); replacementSound.restart(); }
                        function onBodyChanged() { popupCard.restartExpiry(); replacementSound.restart(); }
                        function onExpireTimeoutChanged() { popupCard.restartExpiry(); }
                    }
                    // Fn/performance changes replace one notification object. Coalesce
                    // its property updates so each mode change gets one short tone.
                    Timer {
                        id: replacementSound; interval: 80
                        onTriggered: if (popupCard.modelData && osdRoot.soundCategory(popupCard.modelData) === "controls") osdRoot.playSound(popupCard.modelData)
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

                    // Enter from the side occupied by the bar.
                    NumberAnimation on x {
                        from: BarState.notificationAtLeft ? -360 : 360
                        to: 0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
