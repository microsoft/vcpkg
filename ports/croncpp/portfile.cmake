set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mariusbancila/croncpp
  REF f047a8ad06d252c0b2036ac74b60ebea014c4714 # 2026-08-12
  SHA512 4fedb1dbef4ebc7a82a85596762ac6eae304c645a8121b16209a752aa1b3fd68ff47fef0413f0429860174c9b4bc6780457331d473936d20b99b354e812abd78
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DCRONCPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
