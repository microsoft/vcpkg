vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF v2.3.5
  SHA512 456d428020b6a8926596760a66c7e15df744b7178e752e5d1090d304dfe76636d073aaac6e1e7a99ccd977f4012b8b2b9d5abce29d6d839f456072c9325c87c3
  HEAD_REF master
  PATCHES
    fix-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUNASVG_BUILD_EXAMPLES=OFF
    -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
