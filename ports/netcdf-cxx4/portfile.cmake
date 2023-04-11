string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" HDF5_USE_STATIC_LIBRARIES)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF f8882188267488ef801691e69ad072e3eb217ad8 # v4.3.1
    SHA512 9816acf221d196e21af19d4c3d85484934916e7c018e9b2c96aab9f5660b2f08c5db9cd8254ba3fa5f0aa5f5c5ad7bd3a3aaba559e5e640c5349d44e07a20ed3
    HEAD_REF master
    PATCHES 
        fix-dependecy-hdf5.patch
        export-cmake-targets.patch
)

#Provided by upstream https://github.com/Unidata/netcdf-cxx4/blob/master/netCDFCxxConfig.cmake.in
file(COPY "${CMAKE_CURRENT_LIST_DIR}/netCDFCxxConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNCXX_ENABLE_TESTS=OFF
        -DCMAKE_INSTALL_CMAKECONFIGDIR=share/netCDFCxx
        -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/netCDFCxx PACKAGE_NAME netCDFCxx)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
