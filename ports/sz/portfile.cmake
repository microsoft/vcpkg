vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO szcompressor/SZ3
    REF "v${VERSION}"
    SHA512 1ba3243e5b1122ecb3cd14acde601338e4a0c172998a39792c12b271d73a2804a9edc3712eb44f40b8431589c8fb0d7cd1b4e0199c70c7c10e4c0ec7a04a5725
    HEAD_REF master
    PATCHES
        use-zstd-config.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/tools/zstd")

set(header_only OFF)
if(NOT "hdf5" IN_LIST FEATURES AND NOT "tools" IN_LIST FEATURES)
    set(header_only ON)
    set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5    BUILD_H5Z_FILTER
        openmp  CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
        tools   BUILD_SZ3_BINARY
    INVERTED_FEATURES
        openmp  CMAKE_DISABLE_FIND_PACKAGE_OpenMP
)

vcpkg_find_acquire_program(PKGCONFIG)

# DLLs belong under bin; the plugin copy for HDF5 goes to lib/plugin elsewhere.
set(plugin_dir "lib/plugin")
if(VCPKG_TARGET_IS_WINDOWS)
    set(plugin_dir "bin/plugin")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DSZ3_USE_BUNDLED_ZSTD=OFF
        "-DH5Z_SZ3_PLUGIN_INSTALL_DIR=${plugin_dir}"
        -DBUILD_TESTING=OFF
        -DBUILD_MDZ=OFF
        -DBUILD_PARAVIEW_PLUGIN=OFF
        -DSZ3_DEBUG_TIMINGS=OFF
    MAYBE_UNUSED_VARIABLES
        H5Z_SZ3_PLUGIN_INSTALL_DIR # Only inspected when the hdf5 feature is enabled.
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sz3 CONFIG_PATH lib/cmake/SZ3)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Direct consumers must not need build-system definitions for static linkage.
    # The C API header is only installed with the tools feature.
    if(VCPKG_TARGET_IS_WINDOWS AND "tools" IN_LIST FEATURES)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/SZ3c/sz3c.h"
            "#define SZ3C_API __declspec(dllimport)" "#define SZ3C_API")
    endif()
    if("hdf5" IN_LIST FEATURES)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hdf5_sz3/H5Z_SZ3.hpp"
            "#if defined(HDF5SZ3_STATIC)"
            "#ifndef HDF5SZ3_STATIC\n#define HDF5SZ3_STATIC\n#endif\n#if defined(HDF5SZ3_STATIC)")
    endif()
endif()

if("tools" IN_LIST FEATURES)
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/bin/sz3_smoke_test${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        "${CURRENT_PACKAGES_DIR}/debug/bin/sz3_smoke_test${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
    vcpkg_copy_tools(TOOL_NAMES sz3 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT "hdf5" IN_LIST FEATURES AND NOT "tools" IN_LIST FEATURES)
    # header-only: nothing left but empty directories
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/copyright-and-BSD-license.txt")
