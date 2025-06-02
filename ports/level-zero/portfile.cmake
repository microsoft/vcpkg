vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 de83e691a8ef4f28fcd86aa919f8aae493b84c6b644b04efcc46cec405a3a0f3eab519ab78fda26d65161e8c6776723a090a412f24fa0564679d02258643f9d0
    HEAD_REF master
    PATCHES
        patches/spdlog_include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSTEM_SPDLOG=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
