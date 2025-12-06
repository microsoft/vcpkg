#!/bin/sh
# Dummy exe_wrapper for Android cross-compilation
# Meson requires exe_wrapper for cross builds, but we can't run Android binaries on macOS
# This wrapper simply returns success to satisfy Meson's requirement
exit 0
