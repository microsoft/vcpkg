vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/debug_assert
    REF "v${VERSION}"
    SHA512 0cc2f301e5f604501d29bab0e05ab9b667c1e0160003fc26da4f3edf747c761ff6d409cacc6bbe7fb15cd5caf9d3175fd4e88c0b066e659b41966916fab45ba8
    HEAD_REF v1.3.3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DDEBUG_ASSERT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/debug_assert PACKAGE_NAME debug_assert)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
