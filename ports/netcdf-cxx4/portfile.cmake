string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" HDF5_USE_STATIC_LIBRARIES)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF "v${VERSION}"
    SHA512 b24ad8f4e6cbf6f75d53b1b45ac71d87160e37dddba0ff78a56cb601c27f485ce026f88abbd57b3ff3bf9ebdb5b0eb94fd1107de3d8526c77f124620f386448d
    HEAD_REF main
    PATCHES
        disable-test-plugins.patch
        fix-dependecy-hdf5.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNCXX_ENABLE_TESTS=OFF
        -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/netCDF PACKAGE_NAME netCDFCxx)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
