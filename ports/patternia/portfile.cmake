set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sentomk/patternia
  REF "v${VERSION}"
  SHA512 4d65b63c456f9dca5798194f2771b3b3481ab30469aeddb1fdc28ff47ad2790b9f6d2c4b52261ea36352070c3f6f73e19f84c1c3e5724dbd845886201b650a61
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
