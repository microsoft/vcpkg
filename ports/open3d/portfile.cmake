# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 646a0ac0c1e26b5bc4b874fa7e7bf4c18054fae4
    SHA512 06570c99a6736a116d796503489cd701b4584d85ceff008e728a32ae7ccda4dcade3790ec6d613263909a589899e6cfcbcc6fa61b3bbab1e84bf72cd8e2f7170
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
