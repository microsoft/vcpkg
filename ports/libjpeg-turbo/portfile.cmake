include(vcpkg_common_functions)

vcpkg_download_distfile(GETENV_PATCH
    URLS "https://github.com/libjpeg-turbo/libjpeg-turbo/commit/bd96b30b74fe166fc94218cfc64a097fafdcc05f.diff"
    FILENAME "libjpeg-turbo-bd96b30b74fe166fc94218cfc64a097fafdcc05f.diff"
    SHA512 4cd064521b5e4baba4adf972f9f574f6dd43a2cd3e3ad143ca2cdf0f165024406d4fd2ed094124d0c17c5370394140e82fdd892d3cdc49609acdf8f79db1758c
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF 1.5.3
    SHA512 0e7a2cd9943b610f49b562c20a5c350a50326a87bce1d39f14fe45760ed2f89a0d2d3e3f0de9f6a7714f566aabadec6b2422b592591ebb98bbad600ea411fea7
    HEAD_REF master
    PATCHES
        add-options-for-exes-docs-headers.patch
        linux-cmake.patch
        "${GETENV_PATCH}"
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Rename libraries for static builds
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND EXISTS "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/jpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/turbojpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg.lib")
endif()

file(COPY
    ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/copyright)
vcpkg_copy_pdbs()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/jpeg)

vcpkg_test_cmake(PACKAGE_NAME JPEG MODULE)
