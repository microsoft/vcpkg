vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libplist
    REF "${VERSION}"
    SHA512 19ec0a7877281486f5f4f3b81cba34e498f879f1e5c6db6baa9142936dc11c3fc592ebb62d82b148d8f5a85339ea4d30f705fe4a6036c9c79355a11d03b335b6
    HEAD_REF master
    PATCHES
        001_fix_static_build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPACKAGE_VERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_fixup_pkgconfig()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES plistutil AUTO_CLEAN)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plist/plist.h"
        "#ifdef LIBPLIST_STATIC" "#if 1"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plist/plist.h"
        "#ifdef LIBPLIST_STATIC" "#if 0"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
    "${SOURCE_PATH}/src/jsmn.h"
    "${SOURCE_PATH}/src/time64.c"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
