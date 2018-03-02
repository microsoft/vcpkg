#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zaphoyd/websocketpp
    REF 0.7.0
    SHA512 91a86d4f5120db3f474169bb146f865f82167b1e9eedabec8793b31005e4ce3d22083283bc1b9f9e37fa0da835addcb2b68260a27c753852c06b3b1bb2f3c12e
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/openssl_110.patch
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/websocketpp)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/websocketpp/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/websocketpp/COPYING ${CURRENT_PACKAGES_DIR}/share/websocketpp/copyright)

# Copy the header files
file(COPY "${SOURCE_PATH}/websocketpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")

set(INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(WEBSOCKETPP_VERSION 0.7.0)
configure_file(${SOURCE_PATH}/websocketpp-config.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-config.cmake" @ONLY)
configure_file(${SOURCE_PATH}/websocketpp-configVersion.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-configVersion.cmake" @ONLY)
