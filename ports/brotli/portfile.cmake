vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/brotli
    REF e61745a6b7add50d380cfd7d3883dd6c62fc2c71 # v1.0.9
    SHA512 303444695600b70ce59708e06bf21647d9b8dd33d772c53bbe49320f2f8f95ca8a7d6df2d29b7f36ff99001967e2d28380e0e305d778031940a3a5c6585f9a4f
    HEAD_REF master
    PATCHES
        install.patch
        fix-arm-uwp.patch
        pkgconfig.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBROTLI_DISABLE_TESTS=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-brotli-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-brotli")
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-brotli PACKAGE_NAME unofficial-brotli)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/brotli")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
