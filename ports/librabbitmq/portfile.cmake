vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF "v${VERSION}"
  SHA512 0
  HEAD_REF master
  PATCHES
      fix-uwpwarning.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_TOOLS=OFF
    -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rabbitmq-c CONFIG_PATH lib/cmake/rabbitmq-c)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE-MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
