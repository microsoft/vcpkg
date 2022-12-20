vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF libunibreak_5_0 # libunibreak_5_0
  SHA512 909c12cf5df92f0374050fc7a0ef9e91bc1efe6a5dc5a80f4e2c81a507f1228ecaba417c3ee001e11b2422024bea68cc14eb66e08360ae69f830cdaa18764484
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
