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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "https://chromium.googlesource.com/libyuv/libyuv/+archive/master.tar.gz"
    FILENAME "master.tar.gz"
    SHA512 6eea2d78e8ba2b41d45de41fcde7a5213f0060c1997c6c71b98e4297a496901ae0f6b87edc001cd64f82edf95d9e991906596ecc91c15bbd5e7b1573fe4fa8dd
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-jpeg-and-install.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libyuv RENAME copyright)
file(INSTALL ${CURRENT_PACKAGES_DIR}/debug/share/libyuv/LIBYUVConfig-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libyuv )
# Remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/libyuv)

vcpkg_copy_pdbs()