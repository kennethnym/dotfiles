import os
import sys
import signal
import subprocess
import time
from pathlib import Path
from threading import Thread


def main():
    t = Thread(target=check_dark_mode)
    t.start()


def check_dark_mode():
    while True:
        try:
            result = subprocess.run(["defaults", "read", "-g", "AppleInterfaceStyle"])

            # the command above returns an error if the system is in light mode
            # and returns "Dark" in dark mode
            if result.returncode == 1:
                enable_light_theme()
            else:
                enable_dark_theme()

            time.sleep(3)
        except:
            # the command above returns an error if the system is in light mode
            # and returns "Dark" in dark mode
            enable_light_theme()

            time.sleep(3)


def set_kitty_theme(theme: str):
    kitty_light_theme_conf = Path.home() / "dotfiles" / "kitty" / f"{theme}.conf"
    subprocess.run(
        [
            "kitten",
            "@",
            "--password-env=KITTY_REMOTE_CONTROL_PW",
            "set-colors",
            "--all",
            "--configured",
            kitty_light_theme_conf.resolve().as_posix(),
        ]
    )


def enable_light_theme():
    set_kitty_theme("Catppuccin-Latte")


def enable_dark_theme():
    set_kitty_theme("Catppuccin-Mocha")


if __name__ == "__main__":

    def signal_handler(sig, frame):
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    main()
    signal.pause()
