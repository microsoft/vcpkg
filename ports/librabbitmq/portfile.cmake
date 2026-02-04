vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alanxz/rabbitmq-c
  REF "v${VERSION}"
  SHA512 62b4e92fc270c5bdc5343cfaef5245e29a9b6d8983071a47391a93ae1b766ed7b98a6a546e8528befbc284f5ed17da4647595e94341380bfa76598569191e6c0
  HEAD_REF master
  PATCHES
      fix-uwpwarning.patch
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
