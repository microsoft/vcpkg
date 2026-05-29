vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libplist
    REF ${VERSION}
    SHA512 0477202686fb2f88684af30a97d53fd023ada470dfc7c5d8b32c0d80e09a4641e679522a53c5ad32eae61b21a2d0f1f0c660acd8482ba7951d728b42e4cf5eab
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
