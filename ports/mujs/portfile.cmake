vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ccxvii/mujs
  REF "${VERSION}"
  SHA512 ccffb04171f7ecec2cfa6f0e59859acc911836370a648e4c6703db174631ce316413a64ebf4b32eea3d3b09221ff01861cda91f4b1b9bebf495168f26f90daf5
  HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/mujsConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
    -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME mujs CONFIG_PATH lib/cmake/mujs)
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
