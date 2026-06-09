vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cliquot22/TheiaMCR_C
    REF "${VERSION}"
    SHA512 0  # vcpkg will auto-update this
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Install headers
vcpkg_copy_pdbs()
