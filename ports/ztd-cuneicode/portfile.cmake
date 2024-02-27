if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/cuneicode
  REF 093041aa934b7b09e7ee7300abdc3f54bb57e389
  SHA512 0066fee5cf75fa07dc97934153e4206e4add69f15602526c1953b0302d5a6f8b56256e837a73acee187b0e02e676fba1350ad39b162c4901c624b12fa4e0fb03
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
