vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF v1.4.1
    SHA512 a3d23ea2f9d97a9248d05ecdac5f10bc9b7fffaf9a225e8b1dbd14ace4f7acb33758cca3321774a52d21625a21cb98bb51672f018e8a458f9fff1fb194bec0e6
    HEAD_REF master
    PATCHES
        vcpkg.patch
        ssize_t.patch
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
