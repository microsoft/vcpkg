vcpkg_fail_port_install(ON_TARGET UWP)

vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/CMake-hdf5-1.10.5.tar.gz"
    FILENAME "CMake-hdf5-1.10.5.tar.gz"
    SHA512 a25ea28d7a511f9184d97b5b8cd4c6d52dcdcad2bffd670e24a1c9a6f98b03108014a853553fa2b00d4be7523128b5fd6a4454545e3b17ff8c66fea16a09e962
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF hdf5
    PATCHES
        hdf5_config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES 
     parallel     HDF5_ENABLE_PARALLEL
     cpp          HDF5_BUILD_CPP_LIB
     szip         HDF5_ENABLE_SZIP_SUPPORT
     szip         HDF5_ENABLE_SZIP_ENCODING
     zlib         HDF5_ENABLE_Z_LIB_SUPPORT
                    )

file(REMOVE ${SOURCE_PATH}/config/cmake_ext_mod/FindSZIP.cmake)#Outdated; does not find debug szip
find_library(SZIP_RELEASE NAMES libsz libszip szip sz PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(SZIP_DEBUG NAMES libsz libszip szip sz libsz_D libszip_D szip_D sz_D szip_debug PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/hdf5-1.10.5
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        ${OUT_FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_BUILD_TOOLS=OFF
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share
        "-DSZIP_LIBRARY_DEBUG:PATH=${SZIP_DEBUG}"
        "-DSZIP_LIBRARY_RELEASE:PATH=${SZIP_RELEASE}"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

#Linux build create additional scripts here. I dont know what they are doing so I am deleting them and hope for the best
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/data/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
