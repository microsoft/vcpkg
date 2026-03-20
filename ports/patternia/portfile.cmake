set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO SentoMK/patternia
  REF "v${VERSION}"
  SHA512 482f20b7664ff4cb3931e95c57e582f615063e092c734b6d02c32a97f56250dd8fd41611f2773c6d2c8d10fd924fb9700dcbdbeaa222f98ba2e35638733ed736
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPTN_BUILD_TESTS=OFF
    -DPTN_BUILD_BENCHMARKS=OFF
    -DPTN_BUILD_SAMPLES=OFF
    -DPTN_DEV_INDEX=OFF
    -DPTN_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME patternia CONFIG_PATH lib/cmake/patternia)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
