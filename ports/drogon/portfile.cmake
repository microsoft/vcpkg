vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/drogon
    REF v1.0.0
    SHA512 3ea447bee4be1956018af597d5c97d54ff04a6403cc3a0bda36ed905d459c15db8a5134cad0b68d5f628725c5488f8cb6aabbcd281faf5d62775d739b02d4c45
    HEAD_REF master
    PATCHES
        vcpkg.patch
        pg.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Drogon)
# Copy drogon_ctl
vcpkg_copy_tools(TOOL_NAMES drogon_ctl
                 AUTO_CLEAN)
# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()

