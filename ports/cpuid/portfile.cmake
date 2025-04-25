vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF "v${VERSION}"
    SHA512 26353763461cbbe664ddaa6933cbd9016e3b11d8a056bc8c2b92818dfe3a43fcda76a92270f716eeb00ae61b75288c7079add8d7ac2290a0a0d5c3bd7d898d44
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-LNK2019.patch
        fix-MSVC-warning.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBCPUID_ENABLE_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpuid)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
