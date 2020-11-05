string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" HDF5_USE_STATIC_LIBRARIES)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF c244f2de7818d9562eeadee548811872d4ac2975
    SHA512 59cdc56731316eebb5d33b142e8537a0b10e4ef4c00692a2329e29d2776a50ef031dd6c889e48a61cb43f4c8add3aabbdcee1209a7b81aeb959949b9634d9f58
    HEAD_REF master
    PATCHES 
        fix-dependecy-hdf5.patch
        fix-build-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNCXX_ENABLE_TESTS=OFF
        -DCMAKE_INSTALL_CMAKECONFIGDIR=share/netCDFCxx
        -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/netCDF TARGET_PATH share/netCDFCxx)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
