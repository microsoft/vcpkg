vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ludvikjerabek/getopt-win
    REF v${VERSION}
    SHA512 9ca4e7ed7a1fe7bad9d9ef91b5e65c18a716f4c999818e3dd4f644fc861e1ae12e64255c27f12c0df3b1e44757d3d36c068682dd86d184c6f957b2cabda7bbf3
    HEAD_REF getopt_glibc_2.42_port
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(lib_type_options "-DBUILD_STATIC_LIBS=OFF")
else ()
  set(lib_type_options "-DBUILD_STATIC_LIBS=ON" "-DBUILD_SHARED_LIBS=OFF")
endif ()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${lib_type_options}
    -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/getopt.h"
        "defined(STATIC_GETOPT)"
        "1"
    )
endif()

vcpkg_cmake_config_fixup(
    CONFIG_PATH  "lib/cmake/getopt"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS "enabled")
