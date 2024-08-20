#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zaphoyd/websocketpp
    REF 56123c87598f8b1dd471be83ca841ceae07f95ba # 0.8.2
    SHA512 f185a66e5a7c783254352a6ef87e2e559f681032b7368765d08393ed12bcae76825abed7dcaea73de09df644320409dad46279701f5f469520542a2c9b6a6163
    HEAD_REF master
    PATCHES
      cxx20.patch
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Copy the header files
file(COPY "${SOURCE_PATH}/websocketpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")

set(PACKAGE_INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(WEBSOCKETPP_VERSION 0.8.2)
set(PACKAGE_INIT "
macro(set_and_check)
  set(\${ARGV})
endmacro()
")
configure_file(${SOURCE_PATH}/websocketpp-config.cmake.in "${CURRENT_PACKAGES_DIR}/share/${PORT}/websocketpp-config.cmake" @ONLY)
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
