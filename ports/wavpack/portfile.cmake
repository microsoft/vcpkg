# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/00d9a4ac58a52b52495736be614cb06ba102663c)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbry/WavPack
    REF 00d9a4ac58a52b52495736be614cb06ba102663c
    SHA512 a0d08ac2ff46bd4cc606626c8e0da18a83392722a2e40df18f9e40710e5e147c0a24800174bfdf42ed7a12be4d9679f6302c51d8409724d31ca2a29ab4972481
    HEAD_REF master
    PATCHES
        OpenSSL.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DWAVPACK_INSTALL_DOCS=OFF
        -DWAVPACK_BUILD_PROGRAMS=OFF
        -DWAVPACK_BUILD_COOLEDIT_PLUGIN=OFF
        -DWAVPACK_BUILD_WINAMP_PLUGIN=OFF
        -DBUILD_TESTING=OFF
        -DWAVPACK_BUILD_DOCS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wavpack RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME wavpack)
