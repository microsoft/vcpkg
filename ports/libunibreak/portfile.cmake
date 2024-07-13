vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REGEX REPLACE "^([0-9]*)[.].*" "\\1" MAJOR "${VERSION}")
string(REGEX REPLACE "^.*[.]([0-9]*)" "\\1" MINOR "${VERSION}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF "libunibreak_${MAJOR}_${MINOR}"
  SHA512 a85333d59c78b67b1c05d33ab99c069ba493780d6a98ad5ab00e33235c454b8b33515cac4e815de35533f235be7cf5473550b3a6389f7581ba2f6216d42d38e1
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
