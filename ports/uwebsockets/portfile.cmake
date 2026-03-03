# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 33a5f01dc1247a86f7ccfdcbf87cb5abbbb230a2e5a13aa8128944de4742d6e2e1a3d1b84fa37945cadaca7f867e3e11ec25df9734d6732ee9000f4fb3eb4b06
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

set(UWS_NO_LIBDEFLATE 1)
if("libdeflate" IN_LIST FEATURES)
    set(UWS_NO_LIBDEFLATE 0)
endif()
set(UWS_NO_ZLIB 1)
if("zlib" IN_LIST FEATURES)
    set(UWS_NO_ZLIB 0)
endif()
set(UWS_NO_SIMDUTF 1)
if("simdutf" IN_LIST FEATURES)
    set(UWS_NO_SIMDUTF 0)
endif()
configure_file("${CURRENT_PORT_DIR}/unofficial-uwebsockets-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-uwebsockets/unofficial-uwebsockets-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
