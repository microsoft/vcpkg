vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 555776f8d23aff3beeeb5989cb04a0dfe759d53b10a0bf5542e52013d27b85e7d8feb3e2a765a12fd194453f36a20209eeaa1bdf73d184fff56c52c3e1aeea15
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
