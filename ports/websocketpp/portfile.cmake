#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zaphoyd/websocketpp
    REF 0.8.1
    SHA512 35e0261ed0285acf77d300768819bd380197de8acdf68223e2d7598481b9bfd69cb1653b435139771b1db6c16530c8d8cf9a887a8a6bba3fea126d0da4dbc13c
    HEAD_REF master
    PATCHES
        openssl_110.patch
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/websocketpp)

# Copy the header files
file(COPY "${SOURCE_PATH}/websocketpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")

set(PACKAGE_INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(WEBSOCKETPP_VERSION 0.8.1)
set(PACKAGE_INIT "
macro(set_and_check)
  set(\${ARGV})
endmacro()
")
configure_file(${SOURCE_PATH}/websocketpp-config.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-config.cmake" @ONLY)
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/websocketpp/copyright COPYONLY)
