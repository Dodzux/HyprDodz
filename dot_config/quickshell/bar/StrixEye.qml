import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: eye

    // Strix Core's right visor piece, drawn as geometry instead of being baked
    // into the SVG so it can follow the live wallpaper accent — the same idea
    // as PacmanPellets. Coordinates are in the icon's 128 x 128 viewBox and
    // scale with the taskbar icon, which is 22 px by default.
    Shape {
        width: 128
        height: 128
        anchors.centerIn: parent
        scale: eye.width / 128
        layer.enabled: true
        layer.smooth: true

        ShapePath {
            fillColor: Theme.accent
            strokeColor: "transparent"

            PathPolyline {
                path: [
                    Qt.point(103, 34),
                    Qt.point(68, 48),
                    Qt.point(74, 63),
                    Qt.point(101, 55)
                ]
            }
        }
    }
}
