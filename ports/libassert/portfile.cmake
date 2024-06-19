vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 2d4b49811c78f24783fe2cf96fd0ba43712097bbd1982815c1255378add4f101f788128c0e05b2274d420a5fb46d7cfecf57846fef26a3d5088ed7309019dcab
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
