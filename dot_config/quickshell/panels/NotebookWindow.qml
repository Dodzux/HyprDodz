pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services

// Notes + plan in one window. Note bodies autosave through NotebookState;
// the plan tab reads and writes the same DesktopState as the Planner and the
// bar's task panel, so a task added here is the same task everywhere.
FloatingWindow {
    id: notebook
    visible: false
    title: "Notebook"
    implicitWidth: 1120
    implicitHeight: 780
    minimumSize: Qt.size(720, 500)
    color: Theme.base

    signal openPlannerRequested()

    property bool loading: false
    property bool dirty: false
    property bool planMode: false

    readonly property var page: NotebookState.pageById(NotebookState.selectedId)
    readonly property var listedPages: {
        var query = search.text.trim().toLowerCase();
        if (!query)
            return NotebookState.pages;
        return NotebookState.pages.filter(page => (page.title + "\n" + page.body.slice(0, 400)).toLowerCase().indexOf(query) >= 0);
    }
    readonly property var inks: [Qt.hsla(paletteHue, paletteSaturation, .77),
        Qt.hsla((paletteHue + .09) % 1, paletteSaturation * .85, .78),
        Qt.hsla((paletteHue + .91) % 1, paletteSaturation * .9, .74)]
    readonly property real paletteHue: Theme.accent.hslSaturation > .12 ? Theme.accent.hslHue : .59
    readonly property real paletteSaturation: Math.max(.28, Math.min(.52, Theme.accent.hslSaturation))

    function prettyStamp(value) {
        if (!value)
            return "";
        var date = new Date(value);
        if (isNaN(date.getTime()))
            return "";
        var now = new Date();
        return date.toDateString() === now.toDateString()
            ? Qt.formatTime(date, "HH:mm")
            : Qt.formatDate(date, "d MMM");
    }

    function titleOf(page) {
        return page && page.title.trim() ? page.title.trim() : "Untitled";
    }

    function previewOf(page) {
        if (!page)
            return "";
        var lines = page.body.split("\n");
        for (var i = 0; i < lines.length; i++)
            if (lines[i].trim())
                return lines[i].trim();
        return "";
    }

    function bullet(text) {
        var lines = String(text || "").split("\n");
        var out = [];
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line)
                out.push("• " + line.replace(/^[-*•]\s*/, ""));
        }
        return out.join("\n");
    }

    function planCount(text) {
        var lines = String(text || "").split("\n");
        var count = 0;
        for (var i = 0; i < lines.length; i++)
            if (lines[i].trim())
                count++;
        return count;
    }

    function countLabel(text) {
        var count = planCount(text);
        return count === 1 ? "1 item" : count + " items";
    }

    function touch() {
        dirty = true;
        saveTimer.restart();
    }

    function commit() {
        saveTimer.stop();
        if (!dirty || loading || !NotebookState.ready || !NotebookState.selectedId)
            return;
        NotebookState.updatePage(NotebookState.selectedId, titleEdit.text, bodyEdit.text);
        dirty = false;
    }

    function loadPage(id) {
        commit();
        if (!id && NotebookState.pages.length)
            id = NotebookState.pages[0].id;
        NotebookState.selectPage(id);
        var page = NotebookState.pageById(id);
        loading = true;
        titleEdit.text = page ? page.title : "";
        bodyEdit.text = page ? page.body : "";
        loading = false;
        dirty = false;
        bodyScroll.contentY = 0;
        if (page)
            Qt.callLater(() => bodyEdit.forceActiveFocus());
    }

    function newPage() {
        var id = NotebookState.addPage();
        if (!id)
            return;
        search.text = "";
        planMode = false;
        loadPage(id);
        Qt.callLater(() => titleEdit.forceActiveFocus());
    }

    function deletePage(id) {
        var wasActive = (id === NotebookState.selectedId);
        NotebookState.removePage(id);
        if (wasActive)
            loadPage(NotebookState.selectedId);
    }

    function open(scr) {
        if (scr && !visible)
            screen = scr;
        search.text = "";
        if (NotebookState.ready && NotebookState.pages.length === 0)
            NotebookState.addPage();
        var target = NotebookState.pageById(NotebookState.selectedId)
            ? NotebookState.selectedId
            : (NotebookState.pages.length ? NotebookState.pages[0].id : "");
        loadPage(target);
        visible = true;
        Qt.callLater(() => {
            var window = surface.Window.window;
            if (window)
                window.requestActivate();
        });
    }

    Timer {
        id: saveTimer
        interval: 500
        onTriggered: notebook.commit()
    }

    onVisibleChanged: if (!visible) commit()
    onClosed: visible = false
    Component.onDestruction: commit()

    Connections {
        target: NotebookState
        function onPagesChanged() {
            if (notebook.visible && !NotebookState.pageById(NotebookState.selectedId))
                notebook.loadPage(NotebookState.pages.length ? NotebookState.pages[0].id : "");
        }
        function onReadyChanged() {
            if (notebook.visible && !notebook.page && NotebookState.ready) {
                if (NotebookState.pages.length === 0)
                    NotebookState.addPage();
                notebook.loadPage(NotebookState.selectedId);
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+N"
        context: Qt.WindowShortcut
        enabled: notebook.visible
        onActivated: notebook.newPage()
    }
    Shortcut {
        sequence: "Ctrl+F"
        context: Qt.WindowShortcut
        enabled: notebook.visible
        onActivated: {
            search.forceActiveFocus();
            search.selectAll();
        }
    }
    Shortcut {
        sequence: "Ctrl+P"
        context: Qt.WindowShortcut
        enabled: notebook.visible
        onActivated: {
            notebook.commit();
            notebook.planMode = !notebook.planMode;
        }
    }
    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: notebook.visible
        onActivated: {
            if (search.activeFocus && search.text) {
                search.text = "";
                search.focus = false;
            } else {
                notebook.commit();
                notebook.visible = false;
            }
        }
    }

    Item {
        id: surface
        objectName: "notebook-surface"
        anchors.fill: parent

        RowLayout {
            anchors { fill: parent; margins: 20 }
            spacing: 20

            // ▓▒░ PAGES — search, list, new page
            Rectangle {
                Layout.preferredWidth: 300
                Layout.minimumWidth: 260
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, .015)
                border.width: 1
                border.color: Theme.glassBorder

                ColumnLayout {
                    anchors { fill: parent; margins: 14 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            Layout.fillWidth: true
                            text: "Notebook"
                            color: Theme.text
                            font.family: Theme.fontMain
                            font.pixelSize: 21
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: NotebookState.pages.length === 1 ? "1 page" : NotebookState.pages.length + " pages"
                            color: Theme.subtext0
                            font.family: Theme.fontMain
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 8
                        color: search.activeFocus ? Theme.launcherHoverBg : Theme.glassBg
                        border.width: 1
                        border.color: search.activeFocus ? Theme.accent : Theme.borderMuted
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        TextInput {
                            id: search
                            objectName: "notebook-search"
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.onAccent
                            font.family: Theme.fontMain
                            font.pixelSize: 12
                            selectByMouse: true
                            clip: true
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Search notes…"
                                visible: !search.text
                                color: Theme.subtext0
                                font: search.font
                            }
                        }
                    }

                    ListView {
                        id: pageList
                        objectName: "notebook-pages"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        boundsBehavior: Flickable.StopAtBounds
                        model: ScriptModel {
                            values: notebook.listedPages
                            objectProp: "id"
                        }
                        delegate: Rectangle {
                            id: pageRow
                            required property var modelData
                            width: pageList.width
                            height: 58
                            radius: 10
                            color: NotebookState.selectedId === modelData.id
                                ? Theme.launcherSelectionBg
                                : (rowHover.hovered ? Theme.launcherHoverBg : "transparent")
                            border.width: 1
                            border.color: NotebookState.selectedId === modelData.id
                                ? Theme.launcherSelectionBorder
                                : "transparent"
                            Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                            property bool armed: false
                            HoverHandler { id: rowHover }
                            onModelDataChanged: {
                                armed = false;
                                disarm.stop();
                            }
                            Timer {
                                id: disarm
                                interval: 2500
                                onTriggered: pageRow.armed = false
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notebook.loadPage(pageRow.modelData.id)
                            }

                            ColumnLayout {
                                anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 8; bottomMargin: 8 }
                                spacing: 3
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        Layout.fillWidth: true
                                        text: notebook.titleOf(pageRow.modelData)
                                        color: Theme.text
                                        font.family: Theme.fontMain
                                        font.pixelSize: 12
                                        font.bold: NotebookState.selectedId === pageRow.modelData.id
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                    Text {
                                        Layout.preferredWidth: 42
                                        horizontalAlignment: Text.AlignRight
                                        text: notebook.prettyStamp(pageRow.modelData.updated)
                                        color: Theme.subtext0
                                        font.family: Theme.fontMain
                                        font.pixelSize: 9
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        Layout.fillWidth: true
                                        text: notebook.previewOf(pageRow.modelData) || "No content yet"
                                        color: Theme.subtext0
                                        font.family: Theme.fontMain
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 18
                                        Layout.preferredHeight: 18
                                        radius: 5
                                        color: pageRow.armed ? Theme.hoverBg : "transparent"
                                        opacity: (rowHover.hovered || pageRow.armed || NotebookState.selectedId === pageRow.modelData.id) ? 1 : 0
                                        enabled: opacity > 0
                                        Accessible.role: Accessible.Button
                                        Accessible.name: pageRow.armed ? "Confirm delete" : "Delete note"
                                        Text {
                                            anchors.centerIn: parent
                                            text: pageRow.armed ? "!" : "×"
                                            color: pageRow.armed ? Theme.error : Theme.subtext0
                                            font.family: Theme.fontMain
                                            font.pixelSize: pageRow.armed ? 13 : 14
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (pageRow.armed) {
                                                    notebook.deletePage(pageRow.modelData.id);
                                                } else {
                                                    pageRow.armed = true;
                                                    disarm.restart();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: pageList.count === 0
                            text: search.text.trim() ? "No matches" : "No notes yet"
                            color: Theme.subtext0
                            font.family: Theme.fontMain
                            font.pixelSize: 11
                        }
                    }

                    DesktopButton {
                        Layout.fillWidth: true
                        label: "+ New page"
                        enabled: NotebookState.ready && NotebookState.pages.length < NotebookState.maxPages
                        onClicked: notebook.newPage()
                    }
                }
            }

            // ▓▒░ EDITOR / PLAN
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    DesktopButton {
                        label: "Note"
                        chosen: !notebook.planMode
                        onClicked: {
                            notebook.commit();
                            notebook.planMode = false;
                        }
                    }
                    DesktopButton {
                        label: "Plan"
                        chosen: notebook.planMode
                        onClicked: {
                            notebook.commit();
                            notebook.planMode = true;
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        visible: !notebook.planMode
                        text: bodyEdit.length + " characters"
                        color: Theme.subtext0
                        font.family: Theme.fontMain
                        font.pixelSize: 10
                    }
                    Text {
                        text: !NotebookState.ready ? "Read-only" : (notebook.dirty ? "Editing…" : "Saved")
                        color: !NotebookState.ready ? Theme.error : (notebook.dirty ? Theme.accent : Theme.subtext0)
                        font.family: Theme.fontMain
                        font.pixelSize: 10
                    }
                }

                Item {
                    id: notePane
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !notebook.planMode

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        TextInput {
                            id: titleEdit
                            objectName: "notebook-title"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            topPadding: 4
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.onAccent
                            font.family: Theme.fontMain
                            font.pixelSize: 27
                            font.bold: true
                            selectByMouse: true
                            maximumLength: NotebookState.maxTitleLength
                            enabled: NotebookState.ready && !!notebook.page
                            clip: true
                            onTextChanged: if (!notebook.loading) notebook.touch()
                            onActiveFocusChanged: if (!activeFocus) notebook.commit()
                            onAccepted: bodyEdit.forceActiveFocus()
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Untitled"
                                visible: !titleEdit.text
                                color: Theme.subtext0
                                font: titleEdit.font
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 6
                            spacing: 10
                            Text {
                                text: notebook.page && notebook.page.updated
                                    ? "Edited " + notebook.prettyStamp(notebook.page.updated)
                                    : "New page"
                                color: Theme.subtext0
                                font.family: Theme.fontMain
                                font.pixelSize: 10
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Ctrl+N new · Ctrl+F search · Ctrl+P plan"
                                color: Theme.subtext0
                                opacity: .7
                                font.family: Theme.fontMain
                                font.pixelSize: 9
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 12
                            Layout.preferredHeight: 1
                            color: Theme.glassBorder
                        }

                        Flickable {
                            id: bodyScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.topMargin: 12
                            clip: true
                            contentWidth: width
                            contentHeight: Math.max(height, bodyEdit.implicitHeight + 8)
                            boundsBehavior: Flickable.StopAtBounds

                            TextEdit {
                                id: bodyEdit
                                objectName: "notebook-body"
                                width: bodyScroll.width
                                enabled: NotebookState.ready && !!notebook.page
                                selectByMouse: true
                                wrapMode: TextEdit.Wrap
                                textFormat: TextEdit.PlainText
                                color: Theme.text
                                selectionColor: Theme.accent
                                selectedTextColor: Theme.onAccent
                                font.family: Theme.fontMain
                                font.pixelSize: 14
                                onTextChanged: {
                                    if (notebook.loading)
                                        return;
                                    if (length > NotebookState.maxBodyLength)
                                        remove(NotebookState.maxBodyLength, length);
                                    notebook.touch();
                                }
                                onActiveFocusChanged: if (!activeFocus) notebook.commit()
                                onCursorRectangleChanged: {
                                    if (!activeFocus)
                                        return;
                                    if (cursorRectangle.y < bodyScroll.contentY)
                                        bodyScroll.contentY = cursorRectangle.y;
                                    else if (cursorRectangle.y + cursorRectangle.height > bodyScroll.contentY + bodyScroll.height)
                                        bodyScroll.contentY = cursorRectangle.y + cursorRectangle.height - bodyScroll.height + 8;
                                }
                                Text {
                                    text: "Write something worth keeping…"
                                    visible: !bodyEdit.text
                                    color: Theme.subtext0
                                    font: bodyEdit.font
                                    x: 1
                                    y: 1
                                }
                            }
                        }
                    }
                }

                Item {
                    id: planPane
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: notebook.planMode

                    Flickable {
                        id: planScroll
                        anchors.fill: parent
                        clip: true
                        contentWidth: width
                        contentHeight: planColumn.implicitHeight + 8
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: planColumn
                            width: planScroll.width
                            spacing: 18

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Today"
                                        color: notebook.inks[0]
                                        font.family: Theme.fontMain
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    Text {
                                        text: notebook.countLabel(DesktopState.plannerFocus)
                                        color: Theme.subtext0
                                        font.family: Theme.fontMain
                                        font.pixelSize: 10
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: DesktopState.plannerFocus.trim()
                                        ? notebook.bullet(DesktopState.plannerFocus)
                                        : "Nothing planned for today."
                                    color: DesktopState.plannerFocus.trim() ? notebook.inks[0] : Theme.subtext0
                                    font.family: Theme.fontMain
                                    font.pixelSize: 13
                                    wrapMode: Text.Wrap
                                    textFormat: Text.PlainText
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                spacing: 24
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 6
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            text: "Next"
                                            color: notebook.inks[1]
                                            font.family: Theme.fontMain
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        Text {
                                            text: notebook.countLabel(DesktopState.plannerNext)
                                            color: Theme.subtext0
                                            font.family: Theme.fontMain
                                            font.pixelSize: 10
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: DesktopState.plannerNext.trim()
                                            ? notebook.bullet(DesktopState.plannerNext)
                                            : "Nothing queued."
                                        color: DesktopState.plannerNext.trim() ? notebook.inks[1] : Theme.subtext0
                                        font.family: Theme.fontMain
                                        font.pixelSize: 13
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 6
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            text: "Later"
                                            color: notebook.inks[2]
                                            font.family: Theme.fontMain
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        Text {
                                            text: notebook.countLabel(DesktopState.plannerLater)
                                            color: Theme.subtext0
                                            font.family: Theme.fontMain
                                            font.pixelSize: 10
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: DesktopState.plannerLater.trim()
                                            ? notebook.bullet(DesktopState.plannerLater)
                                            : "Nothing waiting."
                                        color: DesktopState.plannerLater.trim() ? notebook.inks[2] : Theme.subtext0
                                        font.family: Theme.fontMain
                                        font.pixelSize: 13
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: Theme.glassBorder
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text {
                                    Layout.fillWidth: true
                                    text: "To-Do"
                                    color: Theme.text
                                    font.family: Theme.fontMain
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Text {
                                    text: DesktopState.remaining + " open"
                                    color: Theme.subtext0
                                    font.family: Theme.fontMain
                                    font.pixelSize: 10
                                }
                                DesktopButton {
                                    label: "Open Planner"
                                    onClicked: {
                                        notebook.commit();
                                        notebook.visible = false;
                                        notebook.openPlannerRequested();
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 34
                                    radius: 8
                                    color: taskEntry.activeFocus ? Theme.launcherHoverBg : Theme.glassBg
                                    border.width: 1
                                    border.color: taskEntry.activeFocus ? Theme.accent : Theme.borderMuted
                                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                                    TextInput {
                                        id: taskEntry
                                        objectName: "notebook-task-input"
                                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.text
                                        selectionColor: Theme.accent
                                        selectedTextColor: Theme.onAccent
                                        font.family: Theme.fontMain
                                        font.pixelSize: 12
                                        selectByMouse: true
                                        maximumLength: 200
                                        enabled: DesktopState.ready
                                        onAccepted: if (DesktopState.addTask(text)) text = ""
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Add a task…"
                                            visible: !taskEntry.text
                                            color: Theme.subtext0
                                            font: taskEntry.font
                                        }
                                    }
                                }
                                DesktopButton {
                                    label: "+"
                                    enabled: DesktopState.ready && taskEntry.text.trim().length > 0
                                    onClicked: if (DesktopState.addTask(taskEntry.text)) {
                                        taskEntry.text = "";
                                        taskEntry.forceActiveFocus();
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Repeater {
                                    model: DesktopState.tasks
                                    delegate: Rectangle {
                                        id: taskRow
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        radius: 8
                                        color: taskHover.hovered ? Theme.launcherHoverBg : "transparent"
                                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                                        HoverHandler { id: taskHover }
                                        RowLayout {
                                            anchors { fill: parent; leftMargin: 8; rightMargin: 6 }
                                            spacing: 8
                                            Rectangle {
                                                Layout.preferredWidth: 16
                                                Layout.preferredHeight: 16
                                                radius: 4
                                                color: taskRow.modelData.done ? Theme.accent : "transparent"
                                                border.width: 1
                                                border.color: taskRow.modelData.done ? Theme.accent : Theme.subtext0
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: taskRow.modelData.done ? "✓" : ""
                                                    color: Theme.onAccent
                                                    font.pixelSize: 11
                                                }
                                                TapHandler { onTapped: DesktopState.toggleTask(taskRow.modelData.id) }
                                                Accessible.role: Accessible.CheckBox
                                                Accessible.name: taskRow.modelData.text
                                                Accessible.checked: taskRow.modelData.done
                                                Accessible.onPressAction: DesktopState.toggleTask(taskRow.modelData.id)
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: taskRow.modelData.text
                                                textFormat: Text.PlainText
                                                color: taskRow.modelData.done ? Theme.subtext0 : Theme.text
                                                font.family: Theme.fontMain
                                                font.pixelSize: 12
                                                font.strikeout: taskRow.modelData.done
                                                elide: Text.ElideRight
                                                maximumLineCount: 1
                                            }
                                            Rectangle {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                radius: 5
                                                color: removeHover.hovered ? Theme.hoverBg : "transparent"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "×"
                                                    color: Theme.subtext0
                                                    font.family: Theme.fontMain
                                                    font.pixelSize: 14
                                                }
                                                HoverHandler { id: removeHover; cursorShape: Qt.PointingHandCursor }
                                                TapHandler { onTapped: DesktopState.removeTask(taskRow.modelData.id) }
                                                Accessible.role: Accessible.Button
                                                Accessible.name: "Remove task from the mini list"
                                            }
                                        }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 6
                                    text: "Tasks are shared with the bar and the Planner. “×” removes a task from the mini list; the planner keeps it."
                                    color: Theme.subtext0
                                    opacity: .75
                                    font.family: Theme.fontMain
                                    font.pixelSize: 9
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: NotebookState.error !== ""
                    text: NotebookState.error
                    color: Theme.error
                    font.family: Theme.fontMain
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
