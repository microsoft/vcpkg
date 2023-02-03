# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF efd0ed02d5b9ed35bd867060d9e0f680d0ee9c8d
    SHA512 57be6a0f8c86f3f5f909a5cf8294a7c144517348b2f8c75e0907beddc2bf70b8543fb15650018bd94a0a800a4a292ed0f07cd0160a968ea960532ffe952d7297
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
