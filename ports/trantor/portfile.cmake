vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 5db1af18015047fe21cc3808c1996db521bf9961645c928122b4c96dc9e2fdf1af0f915273e0a6d04c4d76647dfced078b8e101175b9f806cd903f034ffecaaf
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-disable-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

vcpkg_copy_pdbs()
