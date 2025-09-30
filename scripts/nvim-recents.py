#!/usr/bin/env python3
import subprocess
import shutil
import os
from typing import List

def get_nvim_recents() -> List[str]:
    try:
        shada_file = os.path.expanduser("/home/szobo/.local/state/nvim/shada/main.shada")
        if not os.path.exists(shada_file):
            print("No shada file found.")
            return []

        result = subprocess.run(
            [
                "nvim",
                "--headless",
                "-c", f"rshada! {shada_file}",
                "-c", "redir! > /dev/stdout",
                "-c", "silent echo v:oldfiles",
                "-c", "redir END",
                "-c", "qa"
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            print("Error running nvim:", result.stderr)
            return []

        output = result.stdout.strip()
        if output.startswith("[") and output.endswith("]"):
            files = eval(output)  # trusted nvim output
        else:
            files = []


        files = [f for f in files if "oil://" in f]
        files = [f.replace("oil://", "") for f in files]

        return [f for f in files if os.path.exists(f)]
    except Exception as e:
        print(f"Error: {e}")
        return []

def process_recents(recents: List[str]) -> List[str]:
    processed = []
    for f in recents:
        entry_str = f" {f}"
        entry_str = entry_str.replace(os.path.expanduser("~"), "~")
        if entry_str.endswith("/"):
            entry_str = entry_str[:-1]
        processed.append(entry_str)
    return processed


def rofi_select(items, prompt="Choose"):
    if not shutil.which("rofi"):
        raise FileNotFoundError("rofi not found in PATH")

    input_data = "\n".join(items).encode("utf-8")

    p = subprocess.Popen(
        ["rofi", "-dmenu", "-p", prompt],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    out, err = p.communicate(input=input_data)
    if p.returncode != 0:
        return None
    selection = out.decode("utf-8").rstrip("\n")
    return selection


if __name__ == "__main__":
    recents = get_nvim_recents()
    processed = process_recents(recents)
    choice = rofi_select(processed, prompt="Neovim recents:")
    if not choice:
        print("No selection (cancelled).")
    else:
        path = choice.split(" ", 1)[1] if " " in choice else choice
        path = os.path.expanduser(path)
        if os.path.exists(path):
            desktop_file = "/home/szobo/.local/share/applications/nvim.desktop"
            subprocess.run(
                ["wezterm", "start", "--", "bash", "-lc", f"cd {path} && nvim ."]
            )
        else:
            print(f"Path does not exist: {path}")
