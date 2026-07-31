"""
kf6-ports updater script.

Updates version and SHA512 hash for a list of kf6 ports based on the latest GitHub archive.
"""

import os
import re
import json
import hashlib
import urllib.request
from pathlib import Path
import time

# ============================================================
# CONFIGURATION - Set version, port list, and paths here
# ============================================================
NEW_VERSION = "6.28.0"           # <-- TARGET VERSION

PORT_LIST = [
    "ecm",
    "karchive",
    "kauth",
    "kbreezeicons",
    "kcodecs",
    "kconfig",
    "kcoreaddons",
    "kcrash",
    "kdbusaddons",
    "kf6-solid",
    "kglobalaccel",
    "kguiaddons",
    "ki18n",
    "kitemmodels",
    "kitemviews",
    "kwidgetsaddons",
    "kwindowsystem",
    "syntax-highlighting",
    "threadweaver"
]

# Automatically resolve the ports directory relative to this script's location
SCRIPT_DIR = Path(__file__).resolve().parent.parent
PORTS_ROOT  = SCRIPT_DIR / "ports"

overall_status = "OK"


# ============================================================
# TERMINAL CONFIGURATION
# ============================================================
COLORS = {
    "GREEN": "\033[92m",
    "YELLOW": "\033[93m",
    "RED": "\033[91m",
    "RESET": "\033[0m"
}

STATUS_PRIORITY = {"OK": 0, "WARN": 1, "ERROR": 2}


def print_status(level, message):
    """Prints a status message with color-coded prefix (only prefix is colored)."""
    if level == "OK":
        prefix = f"{COLORS['GREEN']}[OK]{COLORS['RESET']}"
    elif level == "WARN":
        prefix = f"{COLORS['YELLOW']}[WARN]{COLORS['RESET']}"
    elif level == "ERROR":
        prefix = f"{COLORS['RED']}[ERROR]{COLORS['RESET']}"
    else:
        prefix = f"[{level}]"

    print(f"{prefix}: {message}")


def update_overall_status(new_level):
    """Updates the global worst status if the new level is worse than the current one."""
    global overall_status
    if STATUS_PRIORITY.get(new_level, 0) > STATUS_PRIORITY.get(overall_status, 0):
        overall_status = new_level


def extract_repo_from_cmake(cmake_content: str) -> str | None:
    """Extracts KDE/<project> from REPO definition in vcpkg_from_github block."""
    match = re.search(r'REPO\s+"?KDE/([^"\s]+)"?', cmake_content)
    return match.group(1) if match else None


def fetch_sha512_from_github(repo_name: str, version: str) -> str | None:
    """Downloads the tar.gz archive and returns its SHA512 hash."""
    url = f"https://github.com/KDE/{repo_name}/archive/refs/tags/v{version}.tar.gz"

    try:
        with urllib.request.urlopen(url, timeout=180) as response:
            data = response.read()
        return hashlib.sha512(data).hexdigest().lower()
    except Exception as e:
        print_status("ERROR", f'Failed to fetch archive for "{repo_name}": {e}')
        update_overall_status("ERROR")
    return None


def update_port(port_dir: Path):
    """Updates both portfile.cmake and vcpkg.json for a single port."""
    cmake_path = port_dir / "portfile.cmake"
    json_path  = port_dir / "vcpkg.json"

    # --- 1. Extract REPO & Fetch New Hash ---
    if not cmake_path.exists():
        print_status("WARN", f'No portfile.cmake in "{cmake_path}". Skipping.')
        update_overall_status("WARN")
        return

    cmake_content = cmake_path.read_text(encoding='utf-8')
    repo_name = extract_repo_from_cmake(cmake_content)

    if not repo_name:
        print_status("WARN", f'Could not find REPO definition in "{port_dir}". Skipping.')
        update_overall_status("WARN")
        return

    # Fetch archive and show status on same line
    print(f"Fetching archive for \"{repo_name}\" v{NEW_VERSION}...", end="")
    new_hash = fetch_sha512_from_github(repo_name, NEW_VERSION)

    if new_hash:
        print(f"{COLORS['GREEN']} ok{COLORS['RESET']}\n", end="")

        # --- 2. Update Hash in portfile.cmake ---
        pattern = r'SHA512\s+\S+'

        if re.search(pattern, cmake_content):
            print(f'Updating SHA512 in "{cmake_path}"...', end="")

            try:
                updated_cmake = re.sub(
                    pattern,
                    f'SHA512 {new_hash}',
                    cmake_content
                )
                # Force Unix line endings (LF) and UTF-8 without BOM
                updated_cmake = updated_cmake.replace('\r\n', '\n')

                with open(cmake_path, 'wb') as f:
                    f.write(updated_cmake.encode('utf-8'))
                print(f"{COLORS['GREEN']} ok{COLORS['RESET']}\n", end="")
            except Exception as e:
                print_status("ERROR", f"Failed to write cmake file: {e}")
                update_overall_status("ERROR")
        else:
            print_status("WARN", f'No valid SHA512 pattern found in "{port_dir}". Skipping CMake update.')
            update_overall_status("WARN")
    else:
        print(f"{COLORS['RED']} failed{COLORS['RESET']}\n")

    # --- 3. Update vcpkg.json ---
    if json_path.exists():
        print(f'Updating "{json_path}"...', end="")

        try:
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            data['version'] = NEW_VERSION
            data.pop('port-version', None)  # Remove safely if exists

            serialized = json.dumps(data, indent=2) + '\n'

            with open(json_path, 'wb') as f:
                f.write(serialized.encode('utf-8'))
            print(f"{COLORS['GREEN']} ok{COLORS['RESET']}\n", end="")
        except Exception as e:
            print_status("ERROR", f"Failed to update JSON for \"{port_dir}\": {e}")
            update_overall_status("ERROR")


# ============================================================
# MAIN EXECUTION
# ============================================================
if __name__ == "__main__":
    print(f"Starting kf6-ports update to version {NEW_VERSION}")
    print(f'Using ports root: "{PORTS_ROOT}"')

    if not PORTS_ROOT.is_dir():
        print_status("ERROR", f"Ports directory \"{PORTS_ROOT}\" does not exist.")
        overall_status = "ERROR"
        exit(1)

    for port in PORT_LIST:
        full_port_path = PORTS_ROOT / port
        if not full_port_path.is_dir():
            print_status("WARN", f'Directory "{full_port_path}" does not exist. Skipping.')
            update_overall_status("WARN")
            continue

        update_port(full_port_path)

    # Determine final color based on worst status (entire text colored)
    if overall_status == "ERROR":
        final_color = COLORS["RED"]
    elif overall_status == "WARN":
        final_color = COLORS["YELLOW"]
    else:
        final_color = COLORS["GREEN"]

    print(f"\n=== kf6-PORTS UPDATE COMPLETE ===")
    print(f"Final Result: {final_color}{overall_status}{COLORS['RESET']}")
