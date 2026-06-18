if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KRM7/gapp
  REF "v${VERSION}"
  SHA512 de6e1d9e28590cc569c05fe3b2462245940fcca5c8ffbc2974758062f88d3165e527fdc273bb290eb1080dd899d78b540fc7d0f62d7236b289a63e138484f5f0
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DGAPP_BUILD_TESTS=OFF
    -DGAPP_USE_LTO=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gapp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc/gapp/api")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
