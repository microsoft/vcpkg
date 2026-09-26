vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LimiNode/kurlyk
    REF v1.1.0
    SHA512 aab4df757cb27fb94f434b42a4cdefc53ae73751b8464579f53ab63e398f5bab1a17902d58b056e12baeac72e5e8624556abeec39c01043ed87466a5986a83f3
)

# Simple-WebSocket-Server is header-only and is not a standalone vcpkg port.
# Stage the pinned upstream checkout so Kurlyk's install rules can package the
# headers and their MIT license with the exported CMake target.
vcpkg_from_git(
    OUT_SOURCE_PATH SIMPLE_WS_SOURCE_PATH
    URL https://gitlab.com/eidheim/Simple-WebSocket-Server.git
    REF 7bb2867b9d50ff559c60b99178fd46531daa2c7e
)
file(COPY "${SIMPLE_WS_SOURCE_PATH}/"
     DESTINATION "${SOURCE_PATH}/external/Simple-WebSocket-Server")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKURLYK_BUILD_EXAMPLES=OFF
        -DKURLYK_USE_FALLBACK_ASIO=OFF
        -DKURLYK_USE_FALLBACK_CURL=OFF
        -DKURLYK_USE_FALLBACK_OPENSSL=OFF
        -DKURLYK_USE_FALLBACK_SIMPLE_WS_SERVER=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kurlyk)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/AGENTS.md")
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SIMPLE_WS_SOURCE_PATH}/LICENSE"
)
