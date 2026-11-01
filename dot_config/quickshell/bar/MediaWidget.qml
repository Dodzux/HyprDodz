pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.services

BarItem {
    id: mediaWidget
    property real maximumWidth: 300
    readonly property bool hasTrack: activePlayer && activePlayer.trackTitle !== ""
    readonly property bool hasMedia: hasTrack || CavaService.playback || CavaService.active || CavaService.paused || menu.visible
    property MprisPlayer activePlayer: {
        var players = Mpris.players.values;
        return players.find(p => p.playbackState === MprisPlaybackState.Playing) || players[0] || null;
    }
    readonly property string audioTitle: hasTrack ? activePlayer.trackTitle : "Desktop audio"
    readonly property string audioArtist: hasTrack ? activePlayer.trackArtist : ""
    readonly property bool isPlaying: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
    readonly property bool spectrumShown: !CavaService.paused && (CavaService.active || CavaService.resuming)
    property real spectrumProgress: spectrumShown ? 1 : 0
    readonly property bool layoutAnimating: spectrumTransition.running
    readonly property real playPrefix: hasTrack ? 21 : 0
    Behavior on spectrumProgress { NumberAnimation { id: spectrumTransition; duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
    property real popupAnchorX: 0
    visible: hasMedia
    width: visible ? Math.min(maximumWidth, 20 + playPrefix + miniSpectrum.width + mediaText.width) : 0
    holdDetails: menu.visible
    selected: menu.visible
    Accessible.role: Accessible.Button
    Accessible.name: "Music and audio visualizer"
    Accessible.onPressAction: toggleMedia()
    function toggleMedia() {
        if (activePlayer && activePlayer.canTogglePlaying) activePlayer.togglePlaying();
        else toggleVisualizer();
    }
    function toggleVisualizer() {
        if (!menu.visible) popupAnchorX = mediaText.x + mediaText.width / 2;
        menu.visible = !menu.visible;
    }
    function labelClick(button) {
        if (button === Qt.RightButton) toggleVisualizer();
        else toggleMedia();
    }
    function spectrumClick(button) {
        if (button === Qt.RightButton) CavaService.mirrored = !CavaService.mirrored;
        else toggleVisualizer();
    }
    Keys.onReturnPressed: toggleMedia()
    Keys.onSpacePressed: toggleMedia()
    Keys.onPressed: event => { if (event.key === Qt.Key_V) { toggleVisualizer(); event.accepted = true; } }

    component Spectrum: Item {
        property int count: 28
        property real verticalOrigin: CavaService.mirrored ? 0.5 : 1
        Behavior on verticalOrigin { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Repeater {
            model: parent.count
            Rectangle {
                required property int index
                objectName: "cava-band-" + index
                readonly property real amount: {
                    var values = CavaService.levels;
                    var a = Math.floor(index * 28 / parent.count);
                    var b = Math.max(a + 1, Math.floor((index + 1) * 28 / parent.count));
                    var total = 0;
                    for (var n = a; n < b; n++) total += values[n] || 0;
                    return total / (b - a);
                }
                x: index * (parent.width / parent.count)
                y: (parent.height - height) * parent.verticalOrigin
                width: Math.max(1, parent.width / parent.count - (parent.count > 20 ? 3 : 2))
                height: Math.max(2, parent.height * amount)
                radius: Math.min(width / 2, 3)
                color: Theme.accent
                opacity: CavaService.active ? 0.6 + amount * 0.4 : 0.22
                Behavior on height { NumberAnimation { duration: CavaService.active ? 60 : Theme.motionNormal; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 160 } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

    Item {
        id: contentRow
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, mediaWidget.width - 20)
        height: 26
        Item {
            id: playButton
            width: visible ? 15 : 0
            height: 26
            visible: mediaWidget.hasTrack
            Text { anchors.centerIn: parent; text: mediaWidget.isPlaying ? "󰐊" : "󰏤"; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 14 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: mediaWidget.toggleMedia() }
        }
        Item {
            id: miniSpectrum
            objectName: "mini-cava-spectrum"
            x: mediaWidget.playPrefix
            y: 1
            width: 82 * mediaWidget.spectrumProgress
            height: 24
            visible: width > 0
            opacity: mediaWidget.spectrumProgress
            clip: true
            Spectrum { width: 76; height: 18; y: 3; count: 16 }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => mediaWidget.spectrumClick(mouse.button)
            }
        }
        Text {
            id: mediaText
            x: mediaWidget.playPrefix + miniSpectrum.width
            width: Math.max(0, Math.min(implicitWidth, mediaWidget.maximumWidth - 20 - mediaWidget.playPrefix - miniSpectrum.width))
            height: 26
            verticalAlignment: Text.AlignVCenter
            text: mediaWidget.hasTrack ? activePlayer.trackTitle + (activePlayer.trackArtist ? " - " + activePlayer.trackArtist : "") : "Desktop audio"
            color: Theme.subtext0
            font.family: Theme.fontMain
            font.pixelSize: 11
            font.weight: Font.Bold
            elide: Text.ElideRight
            renderType: Text.NativeRendering
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => mediaWidget.labelClick(mouse.button)
            }
        }
    }
    WheelHandler {
        onWheel: event => {
            if (!mediaWidget.activePlayer) return;
            if (event.angleDelta.y > 0 && mediaWidget.activePlayer.canGoNext) mediaWidget.activePlayer.next();
            else if (event.angleDelta.y < 0 && mediaWidget.activePlayer.canGoPrevious) mediaWidget.activePlayer.previous();
        }
    }

    PopupWindow {
        id: menu
        objectName: "cava-popup"
        visible: false
        grabFocus: true
        anchor.item: mediaWidget
        anchor.rect.x: mediaWidget.popupAnchorX
        anchor.rect.y: mediaWidget.height + 12
        anchor.gravity: Edges.Bottom
        color: "transparent"
        implicitWidth: 306
        implicitHeight: 216
        onVisibleChanged: if (visible) { content.forceActiveFocus(); reveal.restart(); }
        ParallelAnimation {
            id: reveal
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: Theme.motionNormal; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "scale"; from: 0.98; to: 1; duration: Theme.motionNormal; easing.type: Easing.OutCubic }
        }
        Rectangle {
            id: card
            anchors.fill: parent
            color: Theme.glassBg
            radius: Theme.panelRadius
            border.color: Theme.glassBorder
            border.width: 1
            Item {
                id: content
                anchors.fill: parent
                anchors.margins: 16
                focus: true
                Keys.onEscapePressed: menu.visible = false
                Text { objectName: "audio-title"; width: parent.width; elide: Text.ElideRight; text: mediaWidget.audioTitle; color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 14; font.weight: Font.DemiBold }
                Text { y: 23; width: parent.width; elide: Text.ElideRight; text: CavaService.paused ? "Visualizer paused" : (mediaWidget.audioArtist || "System audio"); color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 10 }
                Spectrum { id: popupSpectrum; y: 60; width: parent.width; height: 80 }
                Row {
                    anchors { bottom: parent.bottom; left: parent.left }
                    spacing: 6
                    Rectangle { width: 5; height: 5; radius: 3; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Wallpaper accent"; color: Theme.subtext0; font.family: Theme.fontMain; font.pixelSize: 10 }
                }
                Item {
                    id: pauseControl
                    objectName: "visualizer-pause-control"
                    anchors { bottom: parent.bottom; right: parent.right }
                    width: 116
                    height: 24
                    anchors.bottomMargin: -6
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: CavaService.paused ? "Resume" : "Pause visualizer"
                        color: Theme.text; font.family: Theme.fontMain; font.pixelSize: 10
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: CavaService.paused = !CavaService.paused }
                }
            }
        }
    }
}
