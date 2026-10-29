vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libirecovery
    REF c7b488fbf2a9ab95e451df1319e68662fff7b9b7 # commits on 2023-05-13
    SHA512 a8638b71789c0cedf5913a877ca42fef079c968592b6149dfa578d2dc7840f63c1d1fadd934d7cfbd5139cea2b3a4249886a88b69c3edb19dbd3f893c266f665
    HEAD_REF master
    PATCHES
        001_fix_static_build.patch
        002_fix_api.patch
        003_fix_msvc.patch
        004_fix_tools_msvc.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

if("tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND FEATURE_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_fixup_pkgconfig()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES irecovery AUTO_CLEAN)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libirecovery.h"
        "#ifdef IRECV_STATIC" "#if 1"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libirecovery.h"
        "#ifdef IRECV_STATIC" "#if 0"
    )
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(unofficial-libimobiledevice-glue CONFIG)
if(NOT WIN32 AND NOT APPLE)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(libusb REQUIRED IMPORTED_TARGET libusb-1.0)
endif()
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
