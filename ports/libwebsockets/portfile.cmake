include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO warmcat/libwebsockets
    REF v3.1.0
    SHA512 e2a4c1b25bc6f028654a63fc01a2732e6c63414868f8d3d01fa477752fdabe0f61e8d271fe7dd2734db0e15b1250f6b0101285b6d694f971ec4bf67ba7ee067c
    HEAD_REF master
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

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libwebsockets" TARGET_PATH "share/libwebsockets")
endif()

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
    if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/websockets.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/lib/websockets.lib)
    endif()
endif ()
vcpkg_copy_pdbs()
