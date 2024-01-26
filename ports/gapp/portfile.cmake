if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KRM7/gapp
  REF "v${VERSION}"
  SHA512 463d36c3c41d14a9615dc48b43aebfccdf28177db766941607c2bdb2fed9ae5e876ae7b0bca541809503b35e9ce250a5d3b7246342c035f4a079d50539589ac2
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
