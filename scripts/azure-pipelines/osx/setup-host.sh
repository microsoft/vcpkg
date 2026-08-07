#!/bin/sh
set -e

if ! command -v brew >/dev/null 2>&1; then
    installer="$(mktemp)"
    curl -fsSL -o "$installer" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    NONINTERACTIVE=1 /bin/bash "$installer"
    rm "$installer"
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