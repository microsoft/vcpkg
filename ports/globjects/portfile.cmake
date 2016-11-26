# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/globjects-1.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cginternals/globjects/archive/v1.0.0.zip"
    FILENAME "globjects-1.0.0.zip"
    SHA512 e03ae16786b11891a61f0e2f85b0d98a858d1bad3cf4c45944982d6a753dbaa8b28975dc02153360a5ac0f3be73fe86c91af130cfc0dda7459dd782f16868eeb
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/globjects)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/globjects/LICENSE ${CURRENT_PACKAGES_DIR}/share/globjects/copyright)
