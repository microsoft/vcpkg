vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 e59a5876d160cb06eae11b8d61f4047372475c2ba7f1b161457e42f463f3c819efa18b5073e29033323497984fceafd53bed1047815227dd396adfe832c8c109
    HEAD_REF main
    PATCHES
      target_fix.patch
      runtime_destination.patch
)

vcpkg_list(SET options -DASSERT_USE_EXTERNAL_CPPTRACE=On)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_list(APPEND options -DASSERT_STATIC=On)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libassert"
    CONFIG_PATH "lib/cmake/assert"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
