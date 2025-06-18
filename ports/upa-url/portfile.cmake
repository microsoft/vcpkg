vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 d998e8e61fe018035343e43d937bd673eb4eb5d609263c71eff916611651fa9192715ee1b6da1eeaeab46fa26b94cb57cb4384de9318e5b8e28be0dd90c89468
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DUPA_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "upa" CONFIG_PATH "lib/cmake/upa")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
