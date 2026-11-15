pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Notebook pages. Same persistence contract as DesktopState: one JSON file,
// validated on read, never overwritten when the file cannot be parsed.
//
// The selected page lives in PersistentProperties rather than the JSON file so
// clicking through pages does not rewrite every note body to disk.
Singleton {
    id: state

    readonly property int maxPages: 300
    readonly property int maxTitleLength: 120
    readonly property int maxBodyLength: 50000

    property var pages: []
    property bool ready: false
    property string error: ""

    property alias selectedId: selection.pageId

    PersistentProperties {
        id: selection
        reloadableId: "notebook-selection"
        property string pageId: ""
    }

    function newId() {
        return Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 8);
    }

    function pageById(id) {
        return pages.find(page => page.id === id) || null;
    }

    function stamp(value) {
        var text = String(value || "");
        return text.length <= 40 && /^[0-9T:.+Z-]*$/.test(text) ? text : "";
    }

    function read(content) {
        try {
            var data = JSON.parse(content);
            if (data.version !== 1 || !Array.isArray(data.pages) || data.pages.length > maxPages)
                throw new Error("Invalid format");
            var seen = Object.create(null);
            var list = [];
            data.pages.forEach(entry => {
                if (!entry || typeof entry.id !== "string" || !entry.id || seen[entry.id]
                    || typeof entry.title !== "string" || entry.title.length > maxTitleLength
                    || typeof entry.body !== "string" || entry.body.length > maxBodyLength)
                    throw new Error("Invalid page");
                seen[entry.id] = true;
                list.push({
                    id: entry.id,
                    title: entry.title,
                    body: entry.body,
                    created: stamp(entry.created),
                    updated: stamp(entry.updated)
                });
            });
            pages = list;
            if (!seen[selection.pageId])
                selection.pageId = list.length ? list[0].id : "";
            error = "";
            ready = true;
        } catch (e) {
            error = "Could not read saved notes. The original file has been preserved.";
            ready = false;
        }
    }

    function save() {
        if (!ready)
            return;
        storage.setText(JSON.stringify({ version: 1, pages: pages }, null, 2) + "\n");
    }

    function addPage() {
        if (!ready || pages.length >= maxPages)
            return "";
        var now = new Date().toISOString();
        var page = { id: newId(), title: "", body: "", created: now, updated: now };
        pages = [page].concat(pages);
        selection.pageId = page.id;
        save();
        return page.id;
    }

    function updatePage(id, title, body) {
        if (!ready)
            return false;
        var at = pages.findIndex(page => page.id === id);
        if (at < 0)
            return false;
        title = String(title).replace(/[\r\n]+/g, " ").slice(0, maxTitleLength);
        body = String(body).slice(0, maxBodyLength);
        var page = pages[at];
        if (page.title === title && page.body === body)
            return true;
        var next = pages.slice();
        next[at] = {
            id: page.id,
            title: title,
            body: body,
            created: page.created,
            updated: new Date().toISOString()
        };
        pages = next;
        save();
        return true;
    }

    function removePage(id) {
        if (!ready || !pages.some(page => page.id === id))
            return false;
        var next = pages.filter(page => page.id !== id);
        pages = next;
        if (selection.pageId === id)
            selection.pageId = next.length ? next[0].id : "";
        save();
        return true;
    }

    function selectPage(id) {
        if (!ready || !pages.some(page => page.id === id))
            return;
        selection.pageId = id;
    }

    FileView {
        id: storage
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/hypr/notebook.json"
        printErrors: false
        atomicWrites: true
        onLoaded: state.read(text())
        onLoadFailed: reason => {
            if (reason === FileViewError.FileNotFound) {
                state.pages = [];
                state.ready = true;
            } else {
                state.error = "Cannot access saved notes.";
                state.ready = false;
            }
        }
        onSaveFailed: state.error = "Could not save changes. Notes stay in memory for this session."
    }
}
