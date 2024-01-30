vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 14380d3781dabaff22041c4b9abcbfc591640bbb30a08badc9724ccc6ba817ab895774e37f24311f83b1bd139ad50d232d9eab510a4ede20bf2dff89cd308728
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-uwp.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/License" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()
