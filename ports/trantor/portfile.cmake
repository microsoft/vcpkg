vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 43202240968b90d0e6d211d3b7a918567587e4ad26c360848efee2661cc1d49d35de408db5e2ff7314be879faac99ffa29ffa1f3735f9606d95874130db05250
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
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
