vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}-beta"
    SHA512 cf6e84caf7fbda5a2bc5a89a5ce4fb388283d5f392b60b3247dee89b0ab5a46adbc84d8562febc9d17e97863b7d35e0142e05ba0abeb02d31199c800c5ba72ba
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dyanmic" BUILD_SHARED)

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
