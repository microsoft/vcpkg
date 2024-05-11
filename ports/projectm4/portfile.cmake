vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectM-visualizer/projectm
    REF "f60cd86"
    SHA512 "15b41c198ae4fb3e274babad9cb136d2eeea3460b9dd2197a84d698b47fc247dd318be6160dea3f7fccf46828cd1a455959d8f7cfe07c5cec796ea268ae896e6"
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_TESTING=OFF
      -DENABLE_SDL_UI=OFF
      -DENABLE_SYSTEM_PROJECTM_EVAL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME "projectm4"
  CONFIG_PATH "lib/cmake/projectM4"
  DO_NOT_DELETE_PARENT_CONFIG_PATH
)

vcpkg_cmake_config_fixup(
  PACKAGE_NAME "projectm4playlist"
  CONFIG_PATH "lib/cmake/projectM4Playlist"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
