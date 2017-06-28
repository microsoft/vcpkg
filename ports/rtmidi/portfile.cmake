include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtmidi
    REF  2.1.1
    SHA512 4d378720dd0f7c0e1a87741c088756839878ed56465b053040f70a1e039828fe221a6b1669b77b2fdd146cb192934c5719cc934c2c6a6304f44dbee2972c68e8
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
