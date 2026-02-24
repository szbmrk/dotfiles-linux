#!/usr/bin/env python3
import argparse
import os
from pathlib import Path
import subprocess
import shutil
from typing import Dict

WALLPAPERS_PATH = Path("/home/szobo/Pictures/wallpapers/")
CACHE_PATH = Path("/home/szobo/.cache/wallpaper_switcher/")


def is_image(suffix: str) -> bool:
    return suffix in [".png", ".jpg", ".jpeg"]


def get_wallpapers() -> Dict[str, Path]:
    wallpapers = {
        w.name: w
        for w in WALLPAPERS_PATH.iterdir()
        if w.is_file() and is_image(w.suffix)
    }

    return wallpapers


def rofi_select(wallpapers: Dict[str, Path], prompt: str) -> str:
    if not shutil.which("rofi"):
        raise FileNotFoundError("rofi not found in PATH")

    input = [f"{k}\x00icon\x1f{v}" for k, v in wallpapers.items()]
    input_data = "\n".join(input).encode("utf-8")

    p = subprocess.Popen(
        ["rofi", "-config", "wallpaper-select.rasi", "-dmenu", "-p", prompt],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    out, err = p.communicate(input=input_data)
    if p.returncode != 0:
        return ""

    selection = out.decode("utf-8").rstrip("\n")
    return selection


def save_last_wallpaper(path: Path) -> None:
    os.makedirs(CACHE_PATH, exist_ok=True)
    file = open(CACHE_PATH / "last_selected_wallpaper.txt", mode="w")
    file.write(str(path))
    file.close()


def restore_last_wallpaper() -> None:
    cache_file = CACHE_PATH / "last_selected_wallpaper.txt"
    if cache_file.exists():
        file = open(cache_file, mode="r")
        wallpaper = file.readline().strip("\n")
        file.close()

        subprocess.run(["hyprctl", "hyprpaper", "preload", wallpaper])
        subprocess.run(["hyprctl", "hyprpaper", "wallpaper", ",", wallpaper])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--restore", action="store_true", help="Restores last selected wallpaper"
    )
    args = parser.parse_args()

    if args.restore:
        restore_last_wallpaper()
        exit(0)

    wallpapers = get_wallpapers()
    choice = rofi_select(wallpapers, prompt="Wallpapers:")
    if not choice:
        print("No selection (cancelled).")
    else:
        # subprocess.run(["hyprctl", "hyprpaper", "preload", wallpapers[choice]])
        # subprocess.run(["hyprctl", "hyprpaper", "wallpaper", ",", wallpapers[choice]])
        subprocess.run(
            [
                "awww",
                "img",
                wallpapers[choice],
                "--transition-fps",
                "144",
                "--transition-type",
                "center",
                "--transition-duration",
                "1",
            ]
        )
        save_last_wallpaper(wallpapers[choice])
