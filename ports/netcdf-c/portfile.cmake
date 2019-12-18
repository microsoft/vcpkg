vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF v4.7.0
    SHA512 6602799780105c60ac8c873ed4055c1512dc8bebf98de01e1cce572d113ffb3bf3ca522475b93255c415340f672c55dc6785e0bdbcc39055314683da1d02141a
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        config-pkg-location.patch
        transitive-hdf5.patch
        hdf5.patch
        hdf5_2.patch
        fix-build-error-on-linux.patch
        hdf5_3.patch
        fix_config_errors_and_targets.patch
)

#Remove outdated find modules
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindSZIP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindZLIB.cmake")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(NC_USE_STATIC_CRT ON)
else()
    set(NC_USE_STATIC_CRT OFF)
endif()
#NC_EXTRA_DEPS 
find_library(ZLIB_RELEASE NAMES z zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ZLIB_DEBUG NAMES z zlib zd zlibd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(SZIP_RELEASE NAMES libsz libszip szip sz PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(SZIP_DEBUG NAMES libsz libszip szip sz libsz_D libszip_D szip_D sz_D szip_debug PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
#find_library(CURL_RELEASE NAMES curl libcurl PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
#find_library(CURL_DEBUG NAMES curl_d libcurl_d curld libcurld curl libcurl PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE # netcdf-c configures in the source!
    PREFER_NINJA
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
        -DConfigPackageLocation=share/netcdf
        "-DNC_EXTRA_DEPS=zlib szip"  #The functions checks done by cmake are actual failing due to missing external symbols. This should fix it.
        "-DCURL_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include"
        "-DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include" # the curl variable make the curl checks succesful
        "-DSZIP_LIBRARY:STRING=debug\\\\\\\\\\\;${SZIP_DEBUG}\\\\\\\\\\\;optimized\\\\\\\\\\\;${SZIP_RELEASE}"
    OPTIONS_RELEASE
        "-Dzlib_DEP=${ZLIB_RELEASE}"
        "-Dszip_DEP=${SZIP_RELEASE}"
        "-DSZIP=${SZIP_RELEASE}"
    OPTIONS_DEBUG
        "-Dzlib_DEP=${ZLIB_DEBUG}"
        "-Dszip_DEP=${SZIP_DEBUG}"
        "-DSZIP=${SZIP_DEBUG}"
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/netcdf TARGET_PATH share/netcdf)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
