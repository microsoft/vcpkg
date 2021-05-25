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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # netcdf-c configures in the source!
    OPTIONS
        -DBUILD_UTILITIES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_FILTER_TESTING=OFF
        -DUSE_HDF5=ON
        -DENABLE_DAP_REMOTE_TESTS=OFF
        -DDISABLE_INSTALL_DEPENDENCIES=ON
        -DNC_USE_STATIC_CRT=${NC_USE_STATIC_CRT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "netcdf" CONFIG_PATH "lib/cmake/netCDF")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/nc-config" "${CURRENT_PACKAGES_DIR}/bin/nc-config") # invalid
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
