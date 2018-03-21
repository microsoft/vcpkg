include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse/mosquitto
    REF v1.4.15
    SHA512 428ef9434d3fe022232dcde415fe8cd948d237507d512871803a116230f9e011c10fa01313111ced0946f906e8cc7e26d9eee5de6caa7f82590753a4d087f6fd
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES perl gcc diffutils make)
else()
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils make)
endif()
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LWS_WITH_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LWS_WITH_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLWS_WITH_STATIC=${LWS_WITH_STATIC}
        -DLWS_WITH_SHARED=${LWS_WITH_SHARED}
		-DWITH_SRV=OFF
		-DWITH_WEBSOCKETS=ON
		-DWITH_TLS=ON
		-DWITH_TLS_PSK=ON
		-DWITH_THREADING=ON
		-DVCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}
		-DTARGET_TRIPLET=${TARGET_TRIPLET}
		-DCMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD=OFF
	OPTIONS_RELEASE
		-DENABLE_DEBUG=OFF
		-DOPTIMIZE=1
	OPTIONS_DEBUG
		-DENABLE_DEBUG=ON
		-DDEBUGGABLE=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")
#vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/mosquitto")
#if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/curl)
#    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/curl)
#elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/curl)
#    vcpkg_fixup_cmake_targets(CONFIG_PATH share/curl)
#endif()

file(GLOB EXP_FILES ${CURRENT_PACKAGES_DIR}/*.exp ${CURRENT_PACKAGES_DIR}/debug/lib/*.exp)
file(GLOB LIB_FILES ${CURRENT_PACKAGES_DIR}/*.lib ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
file(GLOB EXE_FILES ${CURRENT_PACKAGES_DIR}/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/aclfile.example)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/mosquitto.conf)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/mosquitto.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/mosquitto_passwd.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/mosquitto_pub.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/mosquitto_sub.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/pskfile.example)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/pwfile.example)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/libwebsockets-test-server)
#file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsConfig.cmake LIBWEBSOCKETSCONFIG_CMAKE)
#string(REPLACE "/../include" "/../../include" LIBWEBSOCKETSCONFIG_CMAKE "${LIBWEBSOCKETSCONFIG_CMAKE}")
#file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsConfig.cmake "${LIBWEBSOCKETSCONFIG_CMAKE}")
#file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-debug.cmake LIBWEBSOCKETSTARGETSDEBUG_CMAKE)
#string(REPLACE "websockets_static.lib" "websockets.lib" LIBWEBSOCKETSTARGETSDEBUG_CMAKE "${LIBWEBSOCKETSTARGETSDEBUG_CMAKE}")
#file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-debug.cmake "${LIBWEBSOCKETSTARGETSDEBUG_CMAKE}")
#file(READ ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-release.cmake LIBWEBSOCKETSTARGETSRELEASE_CMAKE)
#string(REPLACE "websockets_static.lib" "websockets.lib" LIBWEBSOCKETSTARGETSRELEASE_CMAKE "${LIBWEBSOCKETSTARGETSRELEASE_CMAKE}")
#file(WRITE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-release.cmake "${LIBWEBSOCKETSTARGETSRELEASE_CMAKE}")
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebsockets)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/libwebsockets/copyright)
#if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/websockets.lib)
#    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/lib/websockets.lib)
#endif ()
vcpkg_copy_pdbs()
