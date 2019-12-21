vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF b7cd387bee8c661141fabb490f4969587c008c55 # v4.7.3
    SHA512 a55391620fac61e4975fe62907ca21049911afce6190fc12d183d24133a32aae8cd223b97a3fe57fc82d8bdca1a7db451046e3be3c379051624d48b1f56c0332
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        config-pkg-location.patch
        use_targets.patch
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
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/netcdf)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
