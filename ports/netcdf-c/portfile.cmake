vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF 26fba54a58fa02af92d84441ed90b417c1d08161 # v4.7.4
    SHA512 7144374b5bd3574ea422de07ffb30fecc4e5f560f9b46f62762cc0cce511dd33068b8df9244fe94ae3cc7b3a9bb9fe398c7e67c3e5ac2109768e5a9b984f24fb
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        use_targets.patch
        fix-dependency-libmath.patch
        fix-linkage-error.patch
        fix-pkgconfig.patch
        fix-dependency-zlib.patch
        fix-manpage-msys.patch
)

#Remove outdated find modules
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindSZIP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindZLIB.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/windows/FindHDF5.cmake")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(NC_USE_STATIC_CRT ON)
else()
    set(NC_USE_STATIC_CRT OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dap       ENABLE_DAP
        netcdf-4  ENABLE_NETCDF_4
        netcdf-4  USE_HDF5
        tools     BUILD_UTILITIES
    INVERTED_FEATURES
        dap       CMAKE_DISABLE_FIND_PACKAGE_CURL
        netcdf-4  CMAKE_DISABLE_FIND_PACKAGE_HDF5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # netcdf-c configures in the source!
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_FILTER_TESTING=OFF
        -DENABLE_DAP_REMOTE_TESTS=OFF
        -DDISABLE_INSTALL_DEPENDENCIES=ON
        -DNC_USE_STATIC_CRT=${NC_USE_STATIC_CRT}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "netcdf" CONFIG_PATH "lib/cmake/netCDF")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/nc-config" "${CURRENT_PACKAGES_DIR}/bin/nc-config") # invalid
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES  nccopy ncdump ncgen ncgen3
        AUTO_CLEAN
    )
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    # delete bin under non-windows because the dynamic libraries get put in lib
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
