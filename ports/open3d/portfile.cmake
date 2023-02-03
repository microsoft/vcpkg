# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF fd13c161ca4a81e3fcd8011fe239b88007acfda1
    SHA512 03abfdc008644a666cf706d5591e9113cd3ec3f39e2fee1d936e340821ffe4628f7acf8479ef2a529d76f96a9c0f390f9ad8980f49c494db1a559eb019c7f3b4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
