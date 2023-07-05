set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mariusbancila/croncpp
  REF "${VERSION}"
  SHA512 77d4ff1ff121d5a924d79b880045100cb128123a56bd97ba70342316b1d8db283ea0460d24f8a60eb231bd9187c0c8b5237742550d40f06ddbe7cfd03bfc4d48
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
