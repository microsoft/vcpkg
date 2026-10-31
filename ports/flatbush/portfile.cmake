# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chusitoo/flatbush
    REF "v${VERSION}"
    SHA512 2acbf3ee56cd265aff5988ed63e2db4320f65beeb5e50f45ad0e028d14f7d41962d25cd40ce56db35a693d9e110f47fc76c1cf45f60a6aeb4cd01719e8b31009
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
