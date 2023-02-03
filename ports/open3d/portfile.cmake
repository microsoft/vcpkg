# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 5f15943f8169dfee2d331a06ec19302373cb8a45
    SHA512 dca93d6f9eb040895a5b1ea64ef915ead70b54b9e18f882295a21df55e99caeca2222d2eb1ba7bfa21f97b84c478f6ab9250e8e0c5c35d8d205bd34c8bdb43db
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
