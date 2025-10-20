#!/usr/bin/env python3

# Usage: ./update_suitesparse.py <new_version>
#
# Updates the `suitesparse` port and all of its `suitesparse-*` sub-packages
# based on the source archive automatically downloaded of the given version.

import hashlib
import io
import json
import re
import sys
import tarfile
from pathlib import Path

import requests

ports_root = Path(__file__).resolve().parent.parent / "ports"


def download(url):
    print(f"Downloading {url}...")
    r = requests.get(url)
    r.raise_for_status()
    return r.content


def sha512(data):
    sha = hashlib.sha512()
    sha.update(data)
    return sha.hexdigest()


def extract_version(content):
    major = re.search(r"^set *\( *(\w+)_VERSION_MAJOR +(\d+) ", content, re.M).group(2)
    minor = re.search(r"^set *\( *(\w+)_VERSION_MINOR +(\d+) ", content, re.M).group(2)
    sub = re.search(r"^set *\( *(\w+)_VERSION_(?:SUB|PATCH|UPDATE) +(\d+) ", content, re.M).group(2)
    return f"{major}.{minor}.{sub}"


def load_versions(tar_gz_bytes):
    versions = {}
    tar_gz_file = io.BytesIO(tar_gz_bytes)
    with tarfile.open(fileobj=tar_gz_file, mode="r:gz") as tar:
        for member in tar.getmembers():
            if not member.isfile():
                continue
            if m := re.fullmatch(r"SuiteSparse-[^/]+/(\w+)/CMakeLists.txt", member.name):
                name = m.group(1)
                if name in ["Example", "GraphBLAS", "CSparse"]:
                    continue
                content = tar.extractfile(member).read().decode("utf8")
                versions[name] = extract_version(content)
            elif member.name.endswith("GraphBLAS_version.cmake"):
                content = tar.extractfile(member).read().decode("utf8")
                versions["GraphBLAS"] = extract_version(content)
    return versions


def update_manifest(pkg_name, version):
    port_dir = ports_root / pkg_name
    manifest_path = port_dir / "vcpkg.json"
    manifest = json.loads(manifest_path.read_text("utf8"))
    if manifest["version-semver"] == version:
        return False
    manifest["version-semver"] = version
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    return True


def update_portfile(pkg_name, new_version, new_hash):
    port_dir = ports_root / pkg_name
    portfile_path = port_dir / "portfile.cmake"
    content = portfile_path.read_text("utf8")
    content, n = re.subn(r"\bREF v\S+", f"REF v{new_version}", content, re.M)
    if n != 1:
        raise Exception(f"Updating {pkg_name} portfile ref failed!")
    content, n = re.subn(r"\bSHA512 \S+", f"SHA512 {new_hash}", content, re.M)
    if n != 1:
        raise Exception(f"Updating {pkg_name} portfile hash failed!")
    portfile_path.write_text(content)


def update_port(pkg_name, new_version, suitesparse_hash):
    port_dir = ports_root / pkg_name
    if not port_dir.exists():
        raise Exception(f"'{pkg_name}' does not exist!")
    update_manifest(pkg_name, new_version)
    # Always update the tag in vcpkg_from_github() even if version has not changed
    # to avoid having to download multiple versions of the source archive.
    print(f"{pkg_name}: updating...")
    if pkg_name == "suitesparse-graphblas":
        url = f"https://github.com/DrTimothyAldenDavis/GraphBLAS/archive/refs/tags/v{new_version}.tar.gz"
        graphblas_hash = sha512(download(url))
        update_portfile(pkg_name, new_version, graphblas_hash)
    else:
        update_portfile(pkg_name, suitesparse_version, suitesparse_hash)


def main(suitesparse_version):
    suitesparse_url = (
        f"https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v{suitesparse_version}.tar.gz"
    )
    tar_gz_bytes = download(suitesparse_url)
    suitesparse_hash = sha512(tar_gz_bytes)
    print("Reading versions from CMakeLists.txt files...")
    versions = load_versions(tar_gz_bytes)
    for lib, new_version in versions.items():
        pkg_name = "suitesparse-config" if lib == "SuiteSparse_config" else "suitesparse-" + lib.lower()
        update_port(pkg_name, new_version, suitesparse_hash)
    update_manifest("suitesparse", suitesparse_version)
    print("Done!")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./update_suitesparse.py <new_version>")
        sys.exit(1)
    suitesparse_version = sys.argv[1]
    main(suitesparse_version)
