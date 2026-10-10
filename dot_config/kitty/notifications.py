"""Give dedicated Codex and Yazi terminals their desktop identities."""

from pathlib import Path
import re

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


    elif manager is not None and manager.wm_class == "org.yazi.fm":
        notification.application_name = "Yazi"
        notification.icon_names = ()
        notification.icon_path = "/usr/share/icons/hicolor/128x128/apps/yazi.png"
        if notification.title == "kitty":
            notification.title = "Yazi"
            completed = re.fullmatch(
                r"Command .* finished with status: (-?\d+)\.\nClick to focus\.",
                notification.body, re.DOTALL,
            )
            if completed:
                status = completed.group(1)
                notification.body = (
                    "Yazi closed.\nClick to focus." if status == "0" else
                    f"Yazi exited with status {status}.\nClick to focus."
                )

    # False delivers the notification with its existing actions and timing.
    return False
