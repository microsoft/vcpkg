if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/cuneicode
  REF 05f89cbc2ba2b8e8a9136693151235e49ce91119
  SHA512 ac768e5173cba55695e273c2244e97a3a4e839700b108bea52111389655b26147275a545f210d1975748aa4775c1868d1bd128ebe9a5f556c1e38adcaf03fb85
  HEAD_REF main
  PATCHES 
      fix-cmake-install.patch
      fix-c32_state-alignment.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
