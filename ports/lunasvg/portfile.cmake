vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF "v${VERSION}"
  SHA512 05dec8310e04e6b2eeae265f9605446ce2da134b624951fa1dc4f7d3f16e62f5c5f3bfceae29f09111e2e22003310b6fba063945e75ba97e0cef82f7f31d4cae
  HEAD_REF master
  PATCHES
    fix-cmake.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUNASVG_BUILD_EXAMPLES=OFF
    -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lunasvg)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
