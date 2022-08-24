vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/type_safe
    REF v0.2.2
    SHA512 5dbc9e906e066cfc5eb8fd9a308e952e33c7463b5d2abaadd4303ebe8c38a1d8e79865076ad6422f4c56ffa23113b291e3c11d6dd28e73ec3d6fe2e3e7a233a3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME type_safe CONFIG_PATH lib/cmake/type_safe)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
