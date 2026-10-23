//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import qs
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire as Pw
import Quickshell.Services.Notifications as Notifs
import qs.bar
import qs.panels
import Quickshell.Io
import qs.services

ShellRoot {
    id: root

    // Reload feedback matches the desktop glass surface and wallpaper accent.
    PanelWindow {
        id: toast
        property var preferredScreen: root.getFocusedScreen()
        property bool shown: false
        property bool failed: false
        property string details: ""
        property bool copied: false
        property real remaining: 1
        readonly property string logCommand: "qs log --pid " + Quickshell.processId
        readonly property color highlight: failed ? Theme.error : Theme.accent

        visible: shown || card.opacity > 0
        implicitWidth: Math.min(390, screen ? screen.width - 28 : 390)
        implicitHeight: content.implicitHeight + 40
        color: "transparent"
        exclusiveZone: -1
        anchors { top: true; right: true }
        margins { top: 71; right: 14 }
        WlrLayershell.namespace: "quickshell-reload-toast"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        function showMessage(isError, message) {
            var target = preferredScreen || Quickshell.screens[0];
            if (!target) return false;
            screen = target;
            lifetime.stop();
            failed = isError;
            details = message || "";
            copied = false;
            remaining = 1;
            shown = true;
            if (!failed) lifetime.restart();
            return true;
        }
        function dismiss() {
            lifetime.stop();
            shown = false;
        }
        function copyDetails() {
            Quickshell.execDetached(["wl-copy", "--", failed ? details : logCommand]);
            copied = true;
        }

        Connections {
            target: Quickshell
            function onReloadCompleted() {
                if (toast.showMessage(false, "")) Quickshell.inhibitReloadPopup();
            }
            function onReloadFailed(errorString) {
                if (toast.showMessage(true, errorString)) Quickshell.inhibitReloadPopup();
            }
        }

        NumberAnimation {
            id: lifetime
            target: toast
            property: "remaining"
            from: 1
            to: 0
            duration: 4500
            onFinished: toast.dismiss()
        }

        Rectangle {
            id: card
            objectName: "reload-toast-card"
            anchors.fill: parent
            anchors.margins: 4
            radius: 14
            color: Theme.glassBg
            border.width: 1
            border.color: Qt.rgba(toast.highlight.r, toast.highlight.g, toast.highlight.b, 0.38)
            opacity: toast.shown ? 1 : 0
            scale: toast.shown ? 1 : 0.97
            transformOrigin: Item.TopRight
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            ColumnLayout {
                id: content
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 12
                        color: Qt.rgba(toast.highlight.r, toast.highlight.g, toast.highlight.b, 0.12)
                        Text {
                            anchors.centerIn: parent
                            text: toast.failed ? "\uf071" : "\uf00c"
                            font.family: Theme.fontMain
                            font.pixelSize: 16
                            color: toast.highlight
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            Layout.fillWidth: true
                            text: toast.failed ? "Reload needs attention" : "Quickshell updated"
                            textFormat: Text.PlainText
                            color: Theme.text
                            font.family: Theme.fontMain
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: toast.failed ? "Your previous configuration is still running" : "Configuration reloaded successfully"
                            color: Theme.subtext0
                            font.family: Theme.fontMain
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                        }
                    }
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: 8
                        color: closeHover.hovered ? Theme.hoverBg : "transparent"
                        Accessible.role: Accessible.Button
                        Accessible.name: "Dismiss reload message"
                        Text { anchors.centerIn: parent; text: "\u00d7"; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 18 }
                        HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: toast.dismiss() }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    visible: toast.failed
                    text: toast.details
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: 11
                }
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: toast.failed ? "Fix the config and save to retry" : "Changes are live"
                        Layout.fillWidth: true
                        color: Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                    }
                    DesktopButton {
                        label: toast.copied ? "Copied" : toast.failed ? "Copy error" : "Copy log command"
                        onClicked: toast.copyDetails()
                    }
                }
            }
            Rectangle {
                visible: !toast.failed
                anchors { left: parent.left; bottom: parent.bottom; leftMargin: 14; bottomMargin: 6 }
                width: Math.max(0, (card.width - 28) * toast.remaining)
                height: 2
                radius: 1
                color: toast.highlight
                opacity: 0.55
            }
        }
    }



    signal togglePowerMenu()
    signal toggleBarFocus()
    signal toggleCalendar()
    signal toggleWallpaperSelector()
    signal toggleNotifications()
    signal toggleCheatsheet()
    signal toggleNetwork(var scr, real anchorX)
    signal toggleOverview()

    // Notifications that arrived since the history panel was last opened —
    // the count on the bar bell.
    property alias brightnessController: volumeOsd
    property alias unreadNotifications: notificationState.unread
    // Arrival time per notification id; Notification itself has no timestamp.
    readonly property var receivedTimes: {
        var saved = JSON.parse(notificationState.timesJson);
        var dates = {};
        Object.keys(saved).forEach(id => dates[id] = new Date(saved[id]));
        return dates;
    }
    PersistentProperties {
        id: notificationState
        reloadableId: "notification-state"
        property int unread: 0
        property string timesJson: "{}"
    }

    /**
     * Finds the screen matching the currently focused Hyprland monitor.
     * @returns {var} Screen object or null if not found.
     */
    function getFocusedScreen() {
        if (!Hyprland.focusedMonitor) return null;
        var name = Hyprland.focusedMonitor.name;
        return Quickshell.screens.find(scr => scr.name === name) || null;
    }

    /**
     * Shows a singleton overlay panel on the focused screen, or hides it if
     * already visible. Shared by every toggleX signal below.
     * @param {var} panel Panel instance with `visible` and `screen` properties.
     */
    function togglePanel(panel) {
        if (panel.visible) {
            panel.visible = false;
            return;
        }
        var scr = getFocusedScreen();
        if (scr) panel.screen = scr;
        panel.visible = true;
    }

    onTogglePowerMenu: togglePanel(powerMenuPanel)
    onToggleCalendar: togglePanel(calendarPanel)
    onToggleWallpaperSelector: wallpaperSelectorPanel.toggle(getFocusedScreen())
    onToggleNotifications: {
        togglePanel(notificationCenter);
        if (notificationCenter.visible) unreadNotifications = 0;
    }
    onToggleOverview: overviewPanel.toggle(getFocusedScreen())
    onToggleCheatsheet: cheatsheetPanel.toggle(getFocusedScreen())
    onToggleNetwork: (scr, anchorX) => networkPanel.toggle(scr, anchorX)

    // ▓▒░ POWER MENU — SUPER+Backspace (GlobalShortcut registered here to avoid duplication per-monitor)
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-power-menu"
        description: "Toggle power menu"
        onPressed: root.togglePowerMenu()
    }

    // ▓▒░ TOP BAR NAVIGATION — SUPER+B
    GlobalShortcut {
        appid: "quickshell"
        name: "focus-bar"
        description: "Focus the top bar for keyboard navigation"
        onPressed: root.toggleBarFocus()
    }

    // ▓▒░ WALLPAPER SELECTOR
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-wallpaper-selector"
        description: "Toggle wallpaper selector"
        onPressed: root.toggleWallpaperSelector()
    }

    // ▓▒░ KEYBIND CHEATSHEET — SUPER+H (also the bar's keyboard button)
    // Rebuilt 2026-09-23 (panels/Cheatsheet.qml); the old ShortcutsPanel is in
    // ~/.config/config_archive/quickshell/. Name kept so the bind is unchanged.
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-shortcuts"
        description: "Toggle keybind cheatsheet"
        onPressed: root.toggleCheatsheet()
    }

    // ▓▒░ NOTIFICATION HISTORY — SUPER+comma (also the bar bell / right-click clock)
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-notifications"
        description: "Toggle notification history"
        onPressed: root.toggleNotifications()
    }

    // ▓▒░ WINDOW OVERVIEW — SUPER+grave
    GlobalShortcut {
        appid: "quickshell"
        name: "toggle-overview"
        description: "Toggle window overview"
        onPressed: root.toggleOverview()
    }

    // ▓▒░ PIPEWIRE — track default audio sink for volume controls in child components
    Pw.PwObjectTracker {
        objects: {
            var list = [];
            if (Pw.Pipewire.defaultAudioSink) list.push(Pw.Pipewire.defaultAudioSink);
            if (Pw.Pipewire.defaultAudioSource) list.push(Pw.Pipewire.defaultAudioSource);
            return list;
        }
    }

    // ▓▒░ NOTIFICATION SERVER — native Wayland notification daemon
    // Replaces dunst. Receives notifications from all apps via the
    // org.freedesktop.Notifications DBus interface.
    //
    // Every capability below is advertised on purpose: apps check them before
    // sending, and without them Firefox, Chromium and Discord fall back to bare
    // title+body notifications — no buttons, no avatars, no site icons.
    Notifs.NotificationServer {
        id: notificationServer
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true

        // tracked = true is what keeps a notification alive past this handler.
        // Without it quickshell destroys the object on return — there was no
        // history, and every later dismiss() threw "is not a function".
        onNotification: (notification) => {
            notification.tracked = true;
            if (notification.lastGeneration) return;
            var times = JSON.parse(notificationState.timesJson);
            times[notification.id] = new Date().toISOString();
            notificationState.timesJson = JSON.stringify(times);
            if (!notification.transient && !notificationCenter.visible) root.unreadNotifications++;
        }
    }

    // ▓▒░ STATUS BAR — spawned on every connected monitor
    Variants {
        model: Quickshell.screens

        Bar {
            modelData: modelData
        }
    }

    // ▓▒░ NOTIFICATION OSD — floating popups (independent of per-screen bar)
    NotificationOSD {
        notificationServer: notificationServer
        receivedTimes: root.receivedTimes
    }

    // ▓▒░ VOLUME / MIC OSD — follows PipeWire, whatever changed the level
    VolumeOSD { id: volumeOsd }

    // ▓▒░ APP LAUNCHER — SUPER+A (GlobalShortcut registered inside AppLauncher.qml)
    // Replaces: rofi -show drun
    AppLauncher {}
    // ▓▒░ SCREENSHOT PANEL — Print key (GlobalShortcut registered inside ScreenshotPanel.qml)
    // Replaces: ~/.config/rofi/screenshot.sh
    ScreenshotPanel {
        notificationServer: notificationServer
    }

    // ▓▒░ CLIPBOARD PANEL — SUPER+V (GlobalShortcut registered inside ClipboardPanel.qml)
    // Replaces: cliphist list | wofi --dmenu
    ClipboardPanel {}

    // ▓▒░ OVERLAY PANELS (Layer-shell frosted blur matching bar)
    PowerMenu {
        id: powerMenuPanel
    }

    CalendarPanel {
        id: calendarPanel
    }

    // ▓▒░ NETWORK PANEL — drops down from the bar's network item (no shortcut)
    // Rebuilt 2026-09-23; the old one is in ~/.config/config_archive/quickshell/.
    NetworkPanel {
        id: networkPanel
    }

    WallpaperSelector {
        id: wallpaperSelectorPanel
    }

    NotificationCenter {
        id: notificationCenter
        notificationServer: notificationServer
        receivedTimes: root.receivedTimes
    }

    Overview {
        id: overviewPanel
    }

    Cheatsheet {
        id: cheatsheetPanel
    }
}
