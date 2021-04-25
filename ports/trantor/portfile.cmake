vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF v1.4.0
    SHA512 0ec455ef55c3907bef8337b1c14e39af13c65d28c3eac731d3c203ba4e0e67fb87907e3320a54e6ea80a465b1941d39d3cc014dd9fe5443804fe4d1bac3350c2
    HEAD_REF master
    PATCHES
        vcpkg.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Trantor)

# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Handle copyright
file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()
