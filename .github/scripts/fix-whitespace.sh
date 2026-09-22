#!/bin/sh

set -eu

if [ "$#" -eq 0 ]; then
    echo "usage: $0 <file>..." >&2
    exit 2
fi

# Check the resolved sed rather than the OS because GNU sed may be installed on
# macOS. GNU and common minimal Linux implementations accept --version and use
# -i without an argument, while BSD sed rejects --version and requires -i ''.
if sed --version >/dev/null 2>&1; then
    for file do
        case "$file" in -*) file="./$file";; esac
        sed -i -e 's/\r$//' -e 's/[[:blank:]]*$//' "$file"
    done
else
    for file do
        case "$file" in -*) file="./$file";; esac
        sed -i '' -e 's/\r$//' -e 's/[[:blank:]]*$//' "$file"
    done
fi
