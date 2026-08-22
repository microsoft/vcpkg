if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/idk
  REF ad64a1759a506bb0761c7b20c40da8c91865f50e
  SHA512 b6f1afa78b23331ba19116101667bb9dd070deafb9d685f99f165c75ec30d7bfe90443034b6f1882c3186c490f3fc4ed648cdc3fff6fa8450375676d8e9c4727
  HEAD_REF main
  PATCHES 
      fix-cmake-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
