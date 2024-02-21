vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF libunibreak_5_1
  SHA512 c47d6445cab36febb214b31aeb48585a4d3685714588079e84be87019f6e6ffb752e0e0e527232e2d164b1efeeeea64b8b4b21e605ebc60f10fb5a169edc2ed0
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

configure_file("${CMAKE_CURRENT_LIST_DIR}/libunibreak-config.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/libunibreak-config.cmake" @ONLY)

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libunibreak RENAME copyright)
