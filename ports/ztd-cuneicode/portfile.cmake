if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/cuneicode
  REF c4bfc7fba686ddb7e1d69f10943775b99865983b
  SHA512 dcf34a7139be938e3fd3155dd7bc2dc101afdfd364aea00ec4e23cd4d6a4562b6936a3f8b3584c12bbc6bcaa436498e2c4ca5d3aa95f39161639ecd47a11f116
  HEAD_REF main
  PATCHES 
      fix-cmake-install.patch
      fix-ztd-marco.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
