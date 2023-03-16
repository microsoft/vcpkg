vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF "v${VERSION}"
  SHA512 b1843ad1a0d93a304c6d14978c40191ff15e8a1074ec2bea41da79882a2692bbe5dec0a49c4c33881c56d7e5331ff38d1e66f33d0dd8d351e8c2847e077b1565
  HEAD_REF master
  PATCHES
    fix-install.patch
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
