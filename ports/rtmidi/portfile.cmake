include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtmidi
    REF cc887191c3b4cb6697aeba5536d9f4eb423090aa
    SHA512 ae011a678e937d3fbd6c010571bc0209ac1a5b839f2f2ca008a1ca57369bafa5f5a5d768d4e3535bc43c5dfb88dfd41d2f86a0d7d8579a2177dcc0dc04bd5579
    HEAD_REF master
)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/readme DESTINATION ${CURRENT_PACKAGES_DIR}/share/rtmidi RENAME copyright)
