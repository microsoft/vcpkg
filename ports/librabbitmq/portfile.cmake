vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF v0.11.0 
  SHA512 0c3dbb6e2b862e9f25e3f76df798ea272bbd81de2865950b95adf1f1e5791eb20d7c9d5a76cb7d2fda54bad5f12bdf69cbfa7e9fd1afdede6f9ec729ca2287de
  HEAD_REF master
  PATCHES
      fix-uwpwarning.patch
      fix-link-header-files.patch #Remove this patch in the next version
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
