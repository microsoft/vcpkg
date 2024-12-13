# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 542de9c2e007c37b6c25e58d58de6a4aa9b6f19b4b681856e40094d49e5c5c132798e79dc384b4609a8f876491779874e2778c76d7b00c16e53f44f4726739b5
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

set(UWS_NO_ZLIB 1)
if("zlib" IN_LIST FEATURES)
    set(UWS_NO_ZLIB 0)
endif()
configure_file("${CURRENT_PORT_DIR}/unofficial-uwebsockets-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-uwebsockets/unofficial-uwebsockets-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
