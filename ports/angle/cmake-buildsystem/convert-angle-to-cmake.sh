#!/bin/sh
set -e
ANGLE_SRC_DIR="$1"

echo "Translating .gni build files to cmake"
./gni-to-cmake.py "${ANGLE_SRC_DIR}/src/compiler.gni" generated/Compiler.cmake
./gni-to-cmake.py "${ANGLE_SRC_DIR}/src/libGLESv2.gni" generated/GLESv2.cmake
./gni-to-cmake.py "${ANGLE_SRC_DIR}/src/libANGLE/renderer/d3d/BUILD.gn" generated/D3D.cmake --prepend 'src/libANGLE/renderer/d3d/'
./gni-to-cmake.py "${ANGLE_SRC_DIR}/src/libANGLE/renderer/gl/BUILD.gn" generated/GL.cmake --prepend 'src/libANGLE/renderer/gl/'
./gni-to-cmake.py "${ANGLE_SRC_DIR}/src/libANGLE/renderer/metal/BUILD.gn" generated/Metal.cmake --prepend 'src/libANGLE/renderer/metal/'
