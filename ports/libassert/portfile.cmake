vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 6d4c0eec7483e1b202c62c937e8be70d3d8d3c9630498af79172fcbf0f1523de753f864068280430408675cab02c5acd03412c1eb17bd7af65d092e3a754c1fd
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
