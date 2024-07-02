vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO crhowell3/libdis6
  REF "v${VERSION}"
  SHA512 8a6c5b317365e5bd895dd2199ab6ab1944e95e7a3ec653a1480ddbeec501bbe6007f42af8da83d51f4a62cd3134163f74c4e0eb8c5f2905c1335de2d8c2c83f2
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DINSTALL_INCLUDE_DIR=include
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libdis6)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
