vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF cd6173f472b778fa0e558982c59f7183aa5b8e47 # v4.8.1
    SHA512 e965b9c865f31abcd0ae045cb709a41710e72bcf5bd237972cd62688f0f099f1b12be316a448d22315b1c73eb99fae3ea38072e9a3646a4f70ba42507d82f537
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        fix-dependency-zlib.patch
        use_targets.patch
        fix-dependency-libmath.patch
        fix-linkage-error.patch
        fix-pkgconfig.patch
        fix-manpage-msys.patch
        fix-dependency-libzip.patch
        fix-dependency-mpi.patch
)

#Remove outdated find modules
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindSZIP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindZLIB.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/windows/FindHDF5.cmake")

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    set(CRT_OPTION "")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_OPTION -DNC_USE_STATIC_CRT=ON)
else()
    set(CRT_OPTION -DNC_USE_STATIC_CRT=OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dap       ENABLE_DAP
        netcdf-4  ENABLE_NETCDF_4
        hdf5      ENABLE_HDF5
        nczarr    ENABLE_NCZARR
        nczarr-zip    ENABLE_NCZARR_ZIP
        tools     BUILD_UTILITIES
    )

if(NOT ENABLE_DAP AND NOT ENABLE_NCZARR)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_CURL=ON")
endif()

if(ENABLE_HDF5)
    # Fix hdf5 szip support detection for static linkage.
    x_vcpkg_pkgconfig_get_modules(
        PREFIX HDF5
        MODULES hdf5
        LIBRARIES
    )
    if(HDF5_LIBRARIES_RELEASE MATCHES "szip")
        list(APPEND FEATURE_OPTIONS "-DUSE_SZIP=ON")
    endif()
endif()

if(VCPKG_TARGET_IS_UWP)
    string(APPEND VCPKG_C_FLAGS " /wd4996 /wd4703")
    string(APPEND VCPKG_CXX_FLAGS " /wd4996 /wd4703")
endif()

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
        ${CRT_OPTION}
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
