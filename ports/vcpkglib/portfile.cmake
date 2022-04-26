vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO microsoft/vcpkg-tool
  REF 2022-03-30
  SHA512 d1fba2655e04dbf599129e688b40be6b61cc23c41943b5d0d4ac23a7cb5df195fadfe252a8c9ea619d4730352eb40e424ef50919ecfad6e52a76b2b4627dbb16
  HEAD_REF main
  PATCHES
    all-in-one.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Findfmt.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unofficial-vcpkglib)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
