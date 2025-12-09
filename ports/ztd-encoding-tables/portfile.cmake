if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/encoding_tables
  REF 2f4324b3d84db2300d0bf3d0e568a28992df2b55
  SHA512 ec8684bca5673609c0b3014228b6b35647896f8288d6ef85778a7bb8a191c4c92985a11d625e7e5e306b738c16dce232f2604e7cf583ca5e9b76ff4a9f447732
  HEAD_REF main
  PATCHES fix-cmake-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
