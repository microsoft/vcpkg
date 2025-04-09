vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 81d19a35eefeeec184a4c2ad81d14b7c8c357491ba3dd8cd177986310450e2cf6464dc77d6950625ca28d8b74ebc610738746b3a6372dc59be650a2a5edbfe93
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DLIBASSERT_USE_EXTERNAL_CPPTRACE=ON
      -DLIBASSERT_USE_EXTERNAL_MAGIC_ENUM=ON
      -DLIBASSERT_BUILD_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME libassert
    CONFIG_PATH lib/cmake/libassert
)
vcpkg_copy_pdbs()

file(APPEND "${CURRENT_PACKAGES_DIR}/share/libassert/libassert-config.cmake" "find_dependency(magic_enum)")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
