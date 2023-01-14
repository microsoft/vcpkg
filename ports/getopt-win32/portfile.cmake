vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/getopt
    REF 0.1
    SHA512 40e2a901241a5d751cec741e5de423c8f19b105572c7cae18adb6e69be0b408efc6c9a2ecaeb62f117745eac0d093f30d6b91d88c1a27e1f7be91f0e84fdf199
    HEAD_REF master
    PATCHES getopt.h.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(COPY "${SOURCE_PATH}/getopt.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/getopt.h"
        "	#define __GETOPT_H_"
        "	#define __GETOPT_H_\n	#define STATIC_GETOPT"
    )
endif()

vcpkg_cmake_config_fixup(
    CONFIG_PATH  "share/unofficial-getopt-win32"
    PACKAGE_NAME "unofficial-getopt-win32"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS "enabled")
