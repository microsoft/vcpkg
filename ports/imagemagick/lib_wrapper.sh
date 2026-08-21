#!/bin/sh
# lib wrapper: passthrough to the real archiver.
# $REAL_LIB must be set to the actual archiver (lib.exe or llvm-lib path).
# Both llvm-lib and MSVC lib.exe share the same command-line interface.
exec "$REAL_LIB" "$@"
