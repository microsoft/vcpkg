#!/usr/bin/env bash

# Regenerates THIRDPARTY-LICENSES.txt, the attribution file for the Rust crates
# statically linked into the prebuilt rerun_c library that ships inside
# rerun_cpp_sdk.zip.  Run this from the port directory after every version bump,
# against a checkout of rerun-io/rerun at the matching tag.
#
# Requires cargo-about (cargo install cargo-about) and python3.
#
# Usage: ./generate_licenses.sh <path-to-rerun-repo>

set -euo pipefail

if [ $# -ne 1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "Usage: $0 <path-to-rerun-repo>"
	exit 1
fi

PORT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RERUN_DIR="$(cd "$1" && pwd)"

CONFIG_FILE="$(mktemp)"
trap 'rm -f "$CONFIG_FILE"' EXIT

# Every license the dependency tree is currently known to use. cargo-about fails
# on anything not listed here.
cat <<'EOF' >"$CONFIG_FILE"
accepted = [
    "Apache-2.0",
    "MIT",
    "MIT-0",
    "0BSD",
    "Unlicense",
    "BSD-3-Clause",
    "BSD-2-Clause",
    "BSL-1.0",
    "MPL-2.0",
    "Zlib",
    "OFL-1.1",
    "Ubuntu-font-1.0",
    "CC0-1.0",
    "Unicode-3.0",
    "ISC",
    "Apache-2.0 WITH LLVM-exception",
    "CDLA-Permissive-2.0",
    "LGPL-2.1-or-later"
]
EOF

# Point at the C API crate rather than the workspace root; the workspace pulls in
# the viewer and the Python and Rust SDKs, none of which end up in rerun_c.
cargo about generate \
	--manifest-path "$RERUN_DIR/crates/top/rerun_c/Cargo.toml" \
	--config "$CONFIG_FILE" \
	--format json |
	python3 "$PORT_DIR/generate_licenses.py" >"$PORT_DIR/THIRDPARTY-LICENSES.txt"

echo "Generated $PORT_DIR/THIRDPARTY-LICENSES.txt"
