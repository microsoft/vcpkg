#!/bin/sh
set -e

if [ ! -x /opt/homebrew/bin/brew ]; then
    echo "Homebrew must be installed on the host before running this script" >&2
    exit 1
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
grep -Fq '/opt/homebrew/bin/brew shellenv' "$HOME/.zprofile" 2>/dev/null || \
    printf '%s\n' 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
brew install azcopy

if [ ! -x "$HOME/macosvm" ]; then
    archive="$(mktemp)"
    curl -fL -o "$archive" https://github.com/s-u/macosvm/releases/download/0.2-3/macosvm-0.2-3-darwin21.tar.gz
    tar -xvf "$archive" -C "$HOME"
    rm "$archive"
fi