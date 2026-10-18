.pragma library

function rows(text) {
    var query = text.trim().replace(/^>\s*/, "").toLowerCase();
    var match = /^(brightness|volume)\s+(\d{1,3})$/.exec(query);
    if (match) {
        var value = Number(match[2]);
        if (value > 100 || (match[1] === "brightness" && value < 1)) return [];
        return [match[1] === "brightness"
            ? action("brightness", "Brightness " + value + "%", "Set screen brightness", "display-brightness", ["brightnessctl", "-c", "backlight", "-n1", "set", value + "%"])
            : action("volume", "Volume " + value + "%", "Set speaker volume", "audio-volume-high", ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value / 100 + ""])];
    }
    var choices = [
        action("desktop", "Desktop controls", "Bar layout, health and help", "preferences-system", []),
        action("layout", "Arrange bar controls", "Drag controls between the two right islands", "preferences-desktop", []),
        action("health", "Desktop health", "Run diagnostics on demand", "utilities-system-monitor", []),
        action("calculator", "Calculator", "Type = 1920 / 16 · Enter copies the result", "accessories-calculator", []),
        action("wallpaper-undo", "Undo wallpaper change", "Restore the previous wallpaper and theme", "edit-undo", []),
        action("brightness", "Brightness 50%", "Try > brightness 50 · range 1–100", "display-brightness", ["brightnessctl", "-c", "backlight", "-n1", "set", "50%"]),
        action("volume", "Volume 25%", "Try > volume 25 · range 0–100", "audio-volume-high", ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.25"]),
        action("mute", "Mute / unmute speakers", "Toggle speaker audio", "audio-volume-muted", ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]),
        action("mic", "Mute / unmute microphone", "Toggle microphone audio", "microphone-sensitivity-muted", ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
    ];
    return choices.filter(function(item) {
        return !query || item.id.slice(7).startsWith(query);
    });
}

function action(id, name, comment, icon, command) {
    return {id: "action:" + id, name: name, comment: comment, icon: icon,
            command: command, runInTerminal: false, desktopAction: true};
}

// Arithmetic only. No eval, property access, functions, or executable strings.
function calculate(expression) {
    if (expression.length > 256) throw new Error("Expression is too long");
    var input = expression.replace(/×/g, "*").replace(/÷/g, "/");
    var tokens = input.match(/(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[()+\-*/%^]|\S/g) || [];
    if (tokens.length > 100) throw new Error("Expression is too complex");
    var at = 0;
    function atom() {
        var t = tokens[at++];
        if (t === "(") { var n = sum(); if (tokens[at++] !== ")") throw new Error("Close the parentheses"); return n; }
        if (!t || !/^(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/.test(t)) throw new Error("Enter a number");
        return Number(t);
    }
    function unary() {
        if (tokens[at] === "+") { at++; return unary(); }
        if (tokens[at] === "-") { at++; return -unary(); }
        return power();
    }
    function power() {
        var n = atom();
        if (tokens[at] === "^") { at++; n = Math.pow(n, unary()); }
        return n;
    }
    function product() {
        var n = unary();
        while (["*", "/", "%"].indexOf(tokens[at]) >= 0) {
            var op = tokens[at++], r = unary();
            if ((op === "/" || op === "%") && r === 0) throw new Error("Cannot divide by zero");
            n = op === "*" ? n * r : op === "/" ? n / r : n % r;
        }
        return n;
    }
    function sum() {
        var n = product();
        while (tokens[at] === "+" || tokens[at] === "-") { var op = tokens[at++], r = product(); n = op === "+" ? n + r : n - r; }
        return n;
    }
    var result = sum();
    if (at !== tokens.length || !isFinite(result)) throw new Error("Invalid arithmetic expression");
    return String(Number(result.toPrecision(12)));
}

function calculatorRows(text) {
    var expression = text.trim().slice(1).trim();
    if (!expression) return [];
    try {
        var value = calculate(expression);
        return [{id: "calculator:result", name: value, comment: "Enter to copy · " + expression,
                 icon: "accessories-calculator", desktopAction: true, command: ["wl-copy", "--", value]}];
    } catch (error) {
        return [{id: "calculator:error", name: error.message, comment: "Use numbers, parentheses and + − * / % ^",
                 icon: "accessories-calculator", desktopAction: true, command: [], disabled: true}];
    }
}
