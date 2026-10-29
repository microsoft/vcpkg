vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF "v${VERSION}"
  SHA512 8191b1225b21e67d7ae814e1e35ed779464fe7d55a253501f20199c8360bdf6f65f17d30066451a98b449ec4f239e5e4b3004b07f0b3ed522704ab3f07c3306f
  HEAD_REF master
  PATCHES
      fix-uwpwarning.patch
      fix-pkgconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    ssl ENABLE_SSL_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
    -DBUILD_TOOLS=OFF
    -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rabbitmq-c CONFIG_PATH lib/cmake/rabbitmq-c)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
