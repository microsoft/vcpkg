# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF b14ac1e875c71738861c91b44f3d56a2846e3605
    SHA512 8ff633300461bec12e82004b8d652168b4fcb09efcccdb1705a4a29bdc6cdad1a55643f90ee88ac0b5f2101b1df3182da0714df033d9abd5bbbfa4baf6903b9c
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
