#!/usr/bin/env python3
from pathlib import Path
import subprocess
import shutil
from typing import Dict

WALLPAPERS_PATH = Path("/home/szobo/Pictures/wallpapers/")


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

    input_data = "\n".join(wallpapers.keys()).encode("utf-8")

    p = subprocess.Popen(
        ["rofi", "-dmenu", "-p", prompt],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    out, err = p.communicate(input=input_data)
    if p.returncode != 0:
        return ""

    selection = out.decode("utf-8").rstrip("\n")
    return selection


if __name__ == "__main__":
    wallpapers = get_wallpapers()
    choice = rofi_select(wallpapers, prompt="Wallpapers:")
    if not choice:
        print("No selection (cancelled).")
    else:
        subprocess.run(["hyprctl", "hyprpaper", "wallpaper", ",", wallpapers[choice]])
