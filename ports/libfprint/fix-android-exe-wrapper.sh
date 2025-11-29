#!/bin/bash
# Fix Android cross file: add exe_wrapper = false
# This script is called after cross file is generated but before meson setup

CROSS_FILE="$1"
if [ -f "$CROSS_FILE" ]; then
    # Check if exe_wrapper already exists
    if ! grep -q "exe_wrapper" "$CROSS_FILE"; then
        # Add exe_wrapper = false to [properties] section
        # If [properties] exists, append to it; otherwise add new section
        if grep -q "^\[properties\]" "$CROSS_FILE"; then
            sed -i.bak '/^\[properties\]/a\
exe_wrapper = false
' "$CROSS_FILE"
        else
            echo "" >> "$CROSS_FILE"
            echo "[properties]" >> "$CROSS_FILE"
            echo "exe_wrapper = false" >> "$CROSS_FILE"
        fi
    fi
fi

