set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sentomk/patternia
  REF 0cd3b1111a10d0160001b3be384fb008eee7278f # url of v0.9.4 returns 300, so use the commit hash instead
  SHA512 2dcef8489db10d2cad5989f809acd6442c0f7b14d07cf12cf87478acb778f2bf72d25970f0e143f52a6e5134c4f7727f70ac8e1456ba2a11c5c42001ff1da770
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
