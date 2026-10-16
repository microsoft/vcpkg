vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF "v${VERSION}"
    SHA512 3720da8ae61a3d4e32db3d939c6bb86de5e0a26bfd1e2436c0351f44608ca0e2c0a72943bd5b3d00f77252673fbf2760d8d234d7405940080c88d8dce4ee5d64
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-LNK2019.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBCPUID_ENABLE_DOCS=OFF
        -DLIBCPUID_BUILD_DRIVERS=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpuid)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
