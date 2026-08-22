vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REGEX REPLACE "^([0-9]*)[.].*" "\\1" MAJOR "${VERSION}")
string(REGEX REPLACE "^.*[.]([0-9]*)" "\\1" MINOR "${VERSION}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF "libunibreak_${MAJOR}_${MINOR}"
  SHA512 50271605be1645698df7ef5b97ae6bbc75b7228ea1aa26a261f33afd8e264e63c37c190d8d7f3a93f87d60b627a68ec90f2f7f55ef08486e5a8bd667c4a372f6
  HEAD_REF master
  PATCHES
       fix_export.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

configure_file("${CMAKE_CURRENT_LIST_DIR}/libunibreak-config.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/libunibreak-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")
