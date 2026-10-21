# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chusitoo/flatbush
    REF "v${VERSION}"
    SHA512 043a0d3a81790ae3f3fe5b01be20f45c0e81fc0757689075fbccb953861293199cb4947f7761c234ed8b635b85bf2e27a77f7487364a0f1b7496d58d8c96233c
    HEAD_REF master
    PATCHES
        fix-version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/flatbush)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# The configured FLATBUSH_SPAN setting must also apply to consumers that include the header directly.
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/flatbush.h"
    "#define FLATBUSH_FLATBUSH_H"
    "#define FLATBUSH_FLATBUSH_H\n\n#ifndef FLATBUSH_SPAN\n#define FLATBUSH_SPAN\n#endif"
)

vcpkg_download_distfile(
    BOOST_LICENSE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-1.81.0/LICENSE_1_0.txt"
    FILENAME "boost-1.81.0-LICENSE_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${BOOST_LICENSE}")
