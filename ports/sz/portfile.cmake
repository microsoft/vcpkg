vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO szcompressor/SZ3
    REF "v${VERSION}"
    SHA512 157ed2c017c8c9966ad6813b153eec715b00be5cc664a421cf4a7d353a136f55c5f76bd262f39c91d62fa99c0756f50291f1573eb55305541dc8aed50005e689
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
        CMAKE_DISABLE_FIND_PACKAGE_OpenMP
        CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
        H5Z_SZ3_PLUGIN_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sz3 CONFIG_PATH lib/cmake/SZ3)
vcpkg_copy_pdbs()

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
