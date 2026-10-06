"""Give notifications from the Codex terminal its desktop identity."""

from pathlib import Path

from kitty.fast_data_types import get_boss
from kitty.notifications import NotificationCommand


def main(notification: NotificationCommand) -> bool:
    boss = get_boss()
    window = boss.window_id_map.get(notification.channel_id)
    manager = boss.os_window_map.get(window.os_window_id) if window else None

    if manager is not None and manager.wm_class == "codex":
        notification.application_name = "Codex"
        notification.icon_names = ()
        notification.icon_path = str(
            Path.home() / ".local/share/icons/hicolor/scalable/apps/codex-logo.svg"
        )

    # False delivers the notification with its existing actions and timing.
    return False
