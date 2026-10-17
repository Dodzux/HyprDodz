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
