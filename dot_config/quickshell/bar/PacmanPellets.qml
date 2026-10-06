import QtQuick
import qs

Item {
    id: pellets

    // Positions align with the 64 x 64 Pacman SVG. Color stays bound to
    // the theme singleton, including live wallpaper accent changes.
    Rectangle {
        x: pellets.width * 45.3 / 64
        y: pellets.height * 29.3 / 64
        width: pellets.width * 5.4 / 64
        height: pellets.height * 5.4 / 64
        radius: width / 2
        antialiasing: true
        color: Theme.accent
    }

    Rectangle {
        x: pellets.width * 53.8 / 64
        y: pellets.height * 30.3 / 64
        width: pellets.width * 3.4 / 64
        height: pellets.height * 3.4 / 64
        radius: width / 2
        antialiasing: true
        color: Theme.accent
        opacity: 0.65
    }
}
