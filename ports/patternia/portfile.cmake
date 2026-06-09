set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sentomk/patternia
  REF ae21772a77caffc7dbe4734030cf46c518416e2e # url of v0.9.3 returns 300, so use the commit hash instead
  SHA512 2edf6a0f2f34d33777772355fdc5087145f98b5f00f238f1cadb57c380a6a7adb3b46874dde91203193d9afae65b610d1757f1eaace2970cde523ca095d82787
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
