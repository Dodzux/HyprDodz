import QtQuick
import Quickshell
import qs

// Static dot lettering; identity follows the user running this desktop session.
Item {
    id: wordmark
    readonly property string username: Quickshell.env("USER") || Quickshell.env("LOGNAME") || Quickshell.env("HOME").split("/").pop()
    readonly property var letters: username.toUpperCase().split("").map(c => alphabet[c] || alphabet["?"])
    readonly property var alphabet: ({
        "A":[14,17,17,31,17,17,17], "B":[30,17,17,30,17,17,30],
        "C":[14,17,16,16,16,17,14], "D":[30,17,17,17,17,17,30],
        "E":[31,16,16,30,16,16,31], "F":[31,16,16,30,16,16,16],
        "G":[14,17,16,23,17,17,14], "H":[17,17,17,31,17,17,17],
        "I":[31,4,4,4,4,4,31], "J":[7,2,2,2,18,18,12],
        "K":[17,18,20,24,20,18,17], "L":[16,16,16,16,16,16,31],
        "M":[17,27,21,21,17,17,17], "N":[17,25,21,19,17,17,17],
        "O":[14,17,17,17,17,17,14], "P":[30,17,17,30,16,16,16],
        "Q":[14,17,17,17,21,18,13], "R":[30,17,17,30,20,18,17],
        "S":[15,16,16,14,1,1,30], "T":[31,4,4,4,4,4,4],
        "U":[17,17,17,17,17,17,14], "V":[17,17,17,17,17,10,4],
        "W":[17,17,17,21,21,27,17], "X":[17,17,10,4,10,17,17],
        "Y":[17,17,10,4,4,4,4], "Z":[31,1,2,4,8,16,31],
        "0":[14,17,19,21,25,17,14], "1":[4,12,4,4,4,4,14],
        "2":[14,17,1,2,4,8,31], "3":[30,1,1,14,1,1,30],
        "4":[2,6,10,18,31,2,2], "5":[31,16,16,30,1,1,30],
        "6":[14,16,16,30,17,17,14], "7":[31,1,2,4,8,8,8],
        "8":[14,17,17,14,17,17,14], "9":[14,17,17,15,1,1,14],
        "_":[0,0,0,0,0,0,31], "-":[0,0,0,31,0,0,0],
        ".":[0,0,0,0,0,12,12], "?":[14,17,1,2,4,0,4]
    })
    width: 17
    height: letters.length ? (letters.length - 1) * 34 + 24 : 0
    Accessible.name: username
    Repeater {
        model: wordmark.letters
        delegate: Item {
            id: letter
            required property var modelData
            required property int index
            x: 0; y: index * 34
            width: 17; height: 24
            Repeater {
                model: 35
                delegate: Rectangle {
                    required property int index
                    x: (index % 5) * 3.5
                    y: Math.floor(index / 5) * 3.5
                    width: 2.5; height: 2.5; radius: 1.25
                    visible: ((letter.modelData[Math.floor(index / 5)] >> (4 - index % 5)) & 1) !== 0
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.82)
                    antialiasing: true
                }
            }
        }
    }
}
