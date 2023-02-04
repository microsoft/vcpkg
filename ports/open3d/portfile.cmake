# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 4743d2603eea89ca25cea8f49cc2ea766b78dc90
    SHA512 2fd60a7025f229f8f36b2cf26426c5ce76b9c7811f1b3f7ac0008e8e75997c2a1244c6a3e5ea4e6c589f44bed340c80c84500250e979b0226d748a41d0a9a61d
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
