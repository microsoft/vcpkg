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

# Extract from GitHub
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ambrou/fmem
    REF v1.1
    SHA512 09c331e7fb0e7d9b145ff2b643a31b41361c0284e5347f90c2e06e785836b46bc76f9c04f95412f143f0e2214a7691f240fb0c5ad8f166f312c32d04fa4a99df
    HEAD_REF master
)

# Configure with CMAKE
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
        -DBUILD_TESTING=OFF
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmem RENAME copyright)

