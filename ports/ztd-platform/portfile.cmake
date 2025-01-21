if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/platform
  REF d92b8e5b85a4cabae62ad19ccfcc5c3f94ab1a14
  SHA512 d7482bbfa00c6c8226e368fde664ee77e915b4d01ea93e79dffb43b51b44808628c1d3d3daa5e6c8e5cd239dcd4c1ae31c3d0f534df9e1e9bf7a134b24322cfa
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
