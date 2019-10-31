include(vcpkg_common_functions)


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yse/easy_profiler
    REF master
    SHA512 7bec8c2797ffc88eb3eeba489e4565dcbd394c112208532fd4c4bf38b678fe2c90d0a0ed73ef4b6e41b3d2e0b1e74f0bc5f864ecc2be5ada459fef67bfc77dbe
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/easy_profiler RENAME copyright)

vcpkg_copy_pdbs()
