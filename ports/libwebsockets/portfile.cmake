include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO warmcat/libwebsockets
    REF v3.0.1
    SHA512 ba96af918dc53e5fe15792985892e726154ec6cd8b0e6b71ec133e1ac53792c42276fd6ae2c48c274acf4163579d8326e403201a8090fc58be29518c9c5b4304
    HEAD_REF master
    PATCHES
        0001-Fix-UWP.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LWS_WITH_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LWS_WITH_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLWS_WITH_STATIC=${LWS_WITH_STATIC}
        -DLWS_WITH_SHARED=${LWS_WITH_SHARED}
        -DLWS_USE_BUNDLED_ZLIB=OFF
        -DLWS_WITHOUT_TESTAPPS=ON
        -DLWS_IPV6=ON
        -DLWS_HTTP2=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/libwebsockets-test-server)
file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsConfig.cmake LIBWEBSOCKETSCONFIG_CMAKE)
string(REPLACE "/../include" "/../../include" LIBWEBSOCKETSCONFIG_CMAKE "${LIBWEBSOCKETSCONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsConfig.cmake "${LIBWEBSOCKETSCONFIG_CMAKE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-debug.cmake LIBWEBSOCKETSTARGETSDEBUG_CMAKE)
string(REPLACE "websockets_static.lib" "websockets.lib" LIBWEBSOCKETSTARGETSDEBUG_CMAKE "${LIBWEBSOCKETSTARGETSDEBUG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-debug.cmake "${LIBWEBSOCKETSTARGETSDEBUG_CMAKE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-release.cmake LIBWEBSOCKETSTARGETSRELEASE_CMAKE)
string(REPLACE "websockets_static.lib" "websockets.lib" LIBWEBSOCKETSTARGETSRELEASE_CMAKE "${LIBWEBSOCKETSTARGETSRELEASE_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-release.cmake "${LIBWEBSOCKETSTARGETSRELEASE_CMAKE}")
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/copyright)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/websockets.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/lib/websockets.lib)
endif ()
vcpkg_copy_pdbs()
