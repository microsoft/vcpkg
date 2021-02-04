if(EXISTS "${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if mozjpeg is installed. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF 4e52b66f342a803d3b8099b79607e3158d3a241c # 2.0.90
    SHA512 28f6af4b1a93a80dc828d62bc074449a3c5651639f250a2dd67a3572fe3d8a0ac0c9ed07f542465a5a7fe0906fd486c21581f9a115063ef1e891cc387f280fb1
    HEAD_REF master
    PATCHES
        ##workaround for vcpkg bug see #5697 on github for more information
        workaround_cmake_system_processor.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
else()
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=ON)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{_CL_} "-DNO_GETENV -DNO_PUTENV")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_CRT_DLL)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    jpeg7 WITH_JPEG7
    jpeg8 WITH_JPEG8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
        ${FEATURE_OPTIONS}
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libjpeg-turbo)

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom AUTO_CLEAN)

file(INSTALL ${SOURCE_PATH}/LICENSE.md  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
