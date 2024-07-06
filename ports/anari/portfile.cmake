vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/ANARI-SDK
  REF "v${VERSION}"
  SHA512 51937d160a9508c56cf123eda13002c705acff501366710f83da1c62d875f8427cec27f10ea2d05f4637be141fb9a87935f4b0b9f0fabb6bd6a7cca6a4f48ee1
  HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_CTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_HELIDE_DEVICE=OFF
    -DBUILD_TESTING=OFF
    -DBUILD_VIEWER=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
  CONFIG_PATH "lib/cmake/${PORT}-${VERSION}"
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/debug/include" 
  "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/bin" 
    "${CURRENT_PACKAGES_DIR}/debug/bin"
  )
endif()

vcpkg_install_copyright(
  FILE_LIST "${SOURCE_PATH}/LICENSE"
)
