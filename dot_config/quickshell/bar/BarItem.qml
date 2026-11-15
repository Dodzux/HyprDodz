import QtQuick
import qs

// Shared transparent hit area. Hover/press/focus state still drives widgets
// and their detail animations without painting squares inside the islands.
Rectangle {
    id: item

    property bool verticalBar: false
    readonly property bool hovered: hoverHandler.hovered
    // PointHandler takes only a passive grab, so it still sees the press when
    // a widget's own MouseArea / TapHandler takes the click.
    readonly property bool pressed: pressHandler.active
    readonly property bool focused: activeFocus
    // Current-state marker available to widget content and indicators.
    property bool selected: false

    // Reveal details after a short dwell; panels follow their actual width.
    // The delay runs once per hover, never once per animation frame.
    property real panelTargetWidth: width
    readonly property bool detailsRequested: enabled && !verticalBar && (hovered || activeFocus)
    property bool detailsShown: false
    property bool holdDetails: false
    property bool groupHoverHold: false
    onGroupHoverHoldChanged: if (!groupHoverHold && !holdDetails && !detailsRequested) detailsShown = false
    onHoldDetailsChanged: if (!holdDetails && !groupHoverHold && !detailsRequested) detailsShown = false
    onDetailsRequestedChanged: {
        if (detailsRequested) detailsDelay.restart();
        else { detailsDelay.stop(); if (!holdDetails && !groupHoverHold) detailsShown = false; }
    }
    Timer { id: detailsDelay; interval: 110; onTriggered: item.detailsShown = item.detailsRequested }


    height: 28
    radius: 6
    antialiasing: true
    activeFocusOnTab: true

    color: "transparent"
    border.width: 0

    HoverHandler {
        id: hoverHandler
        blocking: false
        cursorShape: Qt.PointingHandCursor
    }

    PointHandler {
        id: pressHandler
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    }
}
