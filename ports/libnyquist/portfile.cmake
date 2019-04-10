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

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ddiakopoulos/libnyquist/archive/d372227a91f36f25321e1dc56dda87577e018897.zip"
    FILENAME "d372227a91f36f25321e1dc56dda87577e018897.zip"
    SHA512 6855fdf864f469eab1d452bfd8adac2e037902cae93730f0906a027ddb1e07420ca29b842c504c4ffbb891aadf7666cc712291f395fae31f655c301d0f2ee3b1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at: 
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    # PATCHES
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

FILE(GLOB_RECURSE DELETE_FILES_WAV ${CURRENT_PACKAGES_DIR}/libwavpack*)
FILE(GLOB_RECURSE DELETE_FILES_OPUS ${CURRENT_PACKAGES_DIR}/libopus*)
SET(DEL ${DELETE_FILES_OPUS}
        ${DELETE_FILES_WAV}
)

file(REMOVE_RECURSE ${DEL})

#file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libwavpack.?)
#file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libopus.?)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxlsxwriter RENAME copyright)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnyquist RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME libnyquist)
