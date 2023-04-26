vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF v1.4.2
  SHA512 2a958cf21672627a7a963c58c277364f45aea2590f5795ffdd28e35c90743c35e3043d0019884528b126197dd3be034b17c2d8347fbd55c7a5b0c021099d6c8a
  HEAD_REF master
  PATCHES
    fix-cpp.patch
    fix-install.patch
    fix-text_and_saving.patch
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
