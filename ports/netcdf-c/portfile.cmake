include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF cf3bd998d3fb1af5405bb9ab8cfb810eeb275842 # v4.7.2
    SHA512 362eb6376617610d1245e553a30b0a4be807efd2b0eab2a4482ac2456588152faf030574416fed1205cf5b25ddd60829f8e227d520004e745563c340b0cf3efb
    HEAD_REF master
    PATCHES
        no-install-deps.patch
        config-pkg-location.patch
        transitive-hdf5.patch
        hdf5.patch
        hdf5_2.patch
        fix-build-error-on-linux.patch
        hdf5_3.patch
)

#Remove outdated find modules
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindSZIP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindZLIB.cmake")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(NC_USE_STATIC_CRT ON)
else()
    set(NC_USE_STATIC_CRT OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
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
