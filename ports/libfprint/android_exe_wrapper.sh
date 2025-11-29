#!/bin/bash
# Simple exe_wrapper for Android cross-compilation
# This wrapper is used by Meson when cross-compiling for Android
# It doesn't actually run the binary (which is for Android), but satisfies Meson's requirement

# For most cases, we can just return success
# Meson uses exe_wrapper to test if binaries can run, but for Android we skip this
exit 0

