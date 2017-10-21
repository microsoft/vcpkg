#header-only library
include(vcpkg_common_functions)
set(VERSION "0.7.0")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/websocketpp-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zaphoyd/websocketpp/archive/${VERSION}.zip"
    FILENAME "websocketpp-${VERSION}.zip"
    SHA512 0cfbc5ed7034758b3666b5154854287441ebeef8e18c4e5f39b62559d4f0e9dda63d79021243c447f57b9855209e1813aeb1c6c475fc98aa71ff03933fc7ac0c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/openssl_110.patch
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/websocketpp/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/websocketpp/COPYING ${CURRENT_PACKAGES_DIR}/share/websocketpp/copyright)

# Copy the header files
file(COPY "${SOURCE_PATH}/websocketpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")

set(INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(WEBSOCKETPP_VERSION ${VERSION})
configure_file (${SOURCE_PATH}/websocketpp-config.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-config.cmake" @ONLY)
configure_file (${SOURCE_PATH}/websocketpp-configVersion.cmake.in "${CURRENT_PACKAGES_DIR}/share/websocketpp/websocketpp-configVersion.cmake" @ONLY)