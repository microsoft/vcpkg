vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebm
    REF libwebm-${VERSION}
    SHA512 9da60f3e7243fb78e0c02e0b6bf8e628552c5b54631960e34bacdf0349ce690984ff9432b8ffa495051858ecc2f4e4a4c1e0b290666058298abf94c3ad99670f
    HEAD_REF master
    PATCHES
        Fix-cmake.patch
        fix-export-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${LIBWEBM_CRT_LINKAGE}
        -DENABLE_SAMPLE_PROGRAMS=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_WEBMTS=OFF
        -DENABLE_WEBMINFO=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libwebm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
