vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF v1.5.8
    SHA512 6c90d3dbbc4e175500dfa8365dd42b1e260c5401b6551fb8f28e3673a6540b0937a66ca9f2ae0cc1ef6b1ba27c6232a053ef5402e5ef36835a51f841354de5c9
    HEAD_REF master
    PATCHES
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
