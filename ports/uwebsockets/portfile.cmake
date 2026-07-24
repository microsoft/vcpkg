# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 5a9e97a2f81c928516b899943641eedc4c3012547f7e92a15aaa1427c9973aafb894e2a124a46a3b4bf6b8af3b64ab26c47a54a70156edfce976e0166a8b4dd4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")
# HTTP/3 headers require a QUIC stack
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3App.h"
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3Context.h"
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3ContextData.h"
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3Request.h"
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3Response.h"
    "${CURRENT_PACKAGES_DIR}/include/uwebsockets/Http3ResponseData.h"
)

set(UWS_USE_LIBDEFLATE 0)
if("libdeflate" IN_LIST FEATURES)
    set(UWS_USE_LIBDEFLATE 1)
endif()
set(UWS_NO_LIBDEFLATE 1)
if("libdeflate" IN_LIST FEATURES)
    set(UWS_NO_LIBDEFLATE 0)
endif()
set(UWS_NO_ZLIB 1)
if("zlib" IN_LIST FEATURES OR "libdeflate" IN_LIST FEATURES)
    set(UWS_NO_ZLIB 0)
endif()
set(UWS_USE_SIMDUTF 0)
if("simdutf" IN_LIST FEATURES)
    set(UWS_USE_SIMDUTF 1)
endif()
set(UWS_NO_SIMDUTF 1)
if("simdutf" IN_LIST FEATURES)
    set(UWS_NO_SIMDUTF 0)
endif()
configure_file("${CURRENT_PORT_DIR}/vcpkg-config.h.in" "${CURRENT_PACKAGES_DIR}/include/uwebsockets/vcpkg-config.h" @ONLY)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uwebsockets/PerMessageDeflate.h"
    "#define UWS_PERMESSAGEDEFLATE_H"
    "#define UWS_PERMESSAGEDEFLATE_H\n#include \"vcpkg-config.h\""
)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uwebsockets/WebSocketProtocol.h"
    "#define UWS_WEBSOCKETPROTOCOL_H"
    "#define UWS_WEBSOCKETPROTOCOL_H\n#include \"vcpkg-config.h\""
)
configure_file("${CURRENT_PORT_DIR}/unofficial-uwebsockets-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-uwebsockets/unofficial-uwebsockets-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    # LICENSE contains Apache-only notice but MoveOnlyFunction.h is MIT-licensed.
    "${SOURCE_PATH}/src/MoveOnlyFunction.h"
)
