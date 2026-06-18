vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF "v${VERSION}"
    SHA512 6b642418bef40848fa0b61a6798c90121e1d31dceee815946bde621e01f50a8353d4cd22bce864af080e4342e036bab9bfe1f61f99083620885f9e252ce11895
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-LNK2019.patch
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
