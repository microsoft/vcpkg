#!/usr/bin/env python3
"""
update_shas.py – Refresh all SHA512 hashes in vcpkg_download_distfile blocks
by downloading each file according to the version in vcpkg.json and re-hashing.

Usage:
    python update_shas.py [vcpkg.json] [portfile.cmake]

Defaults: ./vcpkg.json and ./portfile.cmake
"""

import json
import re
import sys
import hashlib
import tempfile
import os
import urllib.request


def read_version(vcpkg_json_path: str) -> str:
    """Read the 'version' field from vcpkg.json."""
    with open(vcpkg_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    version = data.get("version")
    if not version:
        sys.exit(f"ERROR: No 'version' field found in {vcpkg_json_path}")
    return version


def find_download_blocks(content: str) -> list[dict]:
    """
    Locate every vcpkg_download_distfile( ... ) block.
    Returns a list of dicts containing the URL, old SHA512, and absolute
    character offsets of the hash within the full file text.
    """
    blocks = []
    for m in re.finditer(r"vcpkg_download_distfile\(", content):
        # Manual parenthesis matching to find the closing ')'
        depth = 0
        i = m.end() - 1
        while i < len(content):
            if content[i] == "(":
                depth += 1
            elif content[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        end = i + 1
        block_text = content[m.start():end]

        # Extract the URL string
        url_m = re.search(r'URLS\s+"([^"]+)"', block_text)
        if not url_m:
            continue
        url = url_m.group(1)

        # Extract the existing 128-char hex SHA512
        sha_m = re.search(r"SHA512\s+([0-9a-fA-F]{128})", block_text)
        if not sha_m:
            continue
        old_sha = sha_m.group(1)

        blocks.append({
            "url": url,
            "old_sha": old_sha,
            "sha_abs_start": m.start() + sha_m.start(1),
            "sha_abs_end": m.start() + sha_m.end(1),
        })
    return blocks


def compute_sha512_from_url(url: str) -> str:
    """Download a file from the given URL and return its SHA512 hex digest."""
    tmp_path = None
    try:
        req = urllib.request.Request(
            url, headers={"User-Agent": "vcpkg-sha-updater/1.0"}
        )
        with urllib.request.urlopen(req) as resp, tempfile.NamedTemporaryFile(
            delete=False, suffix=".bin"
        ) as tmp:
            while True:
                chunk = resp.read(1024 * 1024)  # 1 MiB chunks
                if not chunk:
                    break
                tmp.write(chunk)
            tmp_path = tmp.name

        with open(tmp_path, "rb") as f:
            return hashlib.sha512(f.read()).hexdigest()
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.unlink(tmp_path)


def main():
    # --- Parse CLI arguments ---
    vcpkg_json = sys.argv[1] if len(sys.argv) > 1 else "vcpkg.json"
    port_file = sys.argv[2] if len(sys.argv) > 2 else "portfile.cmake"

    for path in (vcpkg_json, port_file):
        if not os.path.isfile(path):
            sys.exit(f"ERROR: File not found: {path}")

    # --- Read version ---
    version = read_version(vcpkg_json)
    print(f"Version from {vcpkg_json}: {version}\n")

    # --- Read portfile ---
    with open(port_file, "r", encoding="utf-8") as f:
        content = f.read()

    blocks = find_download_blocks(content)
    print(f"Found: {len(blocks)} x vcpkg_download_distfile\n")
    if not blocks:
        print("Nothing to update.")
        return

    # --- Replace hashes (back-to-front to keep earlier offsets valid) ---
    new_content = content
    updated = 0

    for blk in reversed(blocks):
        # Substitute the CMake variable with the concrete version string
        url = blk["url"].replace("${VERSION}", version)
        print(f"  URL : {url}")
        print(f"  Old : {blk['old_sha'][:40]}...")

        try:
            new_sha = compute_sha512_from_url(url)
        except Exception as exc:
            print(f"  ERROR: {exc}")
            print()
            continue

        print(f"  New : {new_sha[:40]}...")

        if new_sha == blk["old_sha"]:
            print("  (unchanged)")
        else:
            # Splice in the new hash at the exact character offset
            new_content = (
                new_content[: blk["sha_abs_start"]]
                + new_sha
                + new_content[blk["sha_abs_end"]:]
            )
            updated += 1
        print()

    # --- Write back ---
    with open(port_file, "w", encoding="utf-8", newline="\n") as f:
        f.write(new_content)

    print(f"[OK] {updated} SHA512 hash(es) updated -> {port_file}")


if __name__ == "__main__":
    main()
