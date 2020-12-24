vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF v1.1.0
    SHA512 7177c62644ad941aec446d4e2b4a49ebbae4758dff289ce38a889ec1d2fb52fe968ccf32520bffa6ff6ff478b4752d89b2a798d9e4ce69ae6a81cb024e844487
    HEAD_REF master
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
