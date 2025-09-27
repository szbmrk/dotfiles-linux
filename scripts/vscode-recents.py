#!/usr/bin/env python3
import subprocess
import shutil
import sqlite3
import json
import os
from typing import List

def get_file_path(uri) -> str:
    path = uri.replace("file://", "", 1)
    return path

def get_vscode_recents() -> List[dict]:
        try:
            conn = sqlite3.connect("/home/szobo/.config/Code/User/globalStorage/state.vscdb")
            cursor = conn.cursor()
            cursor.execute("SELECT value FROM ItemTable WHERE key = 'history.recentlyOpenedPathsList'")
            result = cursor.fetchone()
            result_list = []
            if result:
                paths_data = json.loads(result[0]).get("entries", [])
                for path in paths_data:
                    if isinstance(path, dict):
                        if path.get("folderUri"):
                            folder_path =  get_file_path(path.get("folderUri"))
                            if os.path.exists(folder_path):
                                result_list.append({"folder": folder_path})
                        if path.get("fileUri"):
                            file_path = get_file_path(path.get("fileUri"))
                            if os.path.exists(file_path):
                                result_list.append({"file": file_path})
                    else:
                        print(f"Unexpected entry type: {type(path)}")
            else:
                print(f"No data found in {file_path}")
            conn.close()
            return result_list
        except Exception as e:
            print(f"Error: {e}")
            return []

def process_recents(recents: List[dict]) -> List[str]:
    processed = []
    for entry in recents:
        entry_str = ""
        if "folder" in entry:
            entry_str = (f"󰉋 {entry['folder']}")
        elif "file" in entry:
            entry_str = (f"󰈔 {entry['file']}")
        entry_str = entry_str.replace(os.path.expanduser("~"), "~")
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
        stderr=subprocess.PIPE
    )
    out, err = p.communicate(input=input_data)
    if p.returncode != 0:
        return None
    selection = out.decode("utf-8").rstrip("\n")
    return selection

if __name__ == "__main__":
    recents = get_vscode_recents()
    choice = rofi_select(process_recents(recents), prompt="Vscode recents:")
    if choice is None or choice == "":
        print("No selection (cancelled).")
    else:
        choice = choice.replace("~", os.path.expanduser("~"))
        subprocess.run(["code", choice.split(" ", 1)[1]])
