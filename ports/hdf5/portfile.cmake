# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
# set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hdf5-1.8.18)
# vcpkg_download_distfile(ARCHIVE
#     URLS "https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar.bz2"
#     FILENAME "hdf5-1.8.18.tar.bz2"
#     SHA512 01f6d14bdd3be2ced9c63cc9e1820cd7ea11db649ff9f3a3055c18c4b0fffe777fd23baad536e3bce31c4d76fe17db64a3972762e1bb4d232927c1ca140e72b2
# )
# vcpkg_extract_source_archive(${ARCHIVE})
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CMake-hdf5-1.10.0-patch1/hdf5-1.10.0-patch1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://hdf4.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/CMake-hdf5-1.10.0-patch1.zip"
    FILENAME "CMake-hdf5-1.10.0-patch1.zip"
    SHA512 ec2edb43438661323be5998ecf64c4dd537ddc7451e31f89390260d16883e60a1ccc1bf745bcb809af22f2bf7157d50331a33910b8ebf5c59cd50693dfb2ef8f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-szip-config.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-static-libs.patch
        ${CMAKE_CURRENT_LIST_DIR}/link-libraries-private.patch
)

set(DISABLE_STATIC_LIBS OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(DISABLE_STATIC_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DDISABLE_STATIC_LIBS=${DISABLE_STATIC_LIBS}
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_BUILD_TOOLS=OFF
        -DHDF5_BUILD_CPP_LIB=OFF
        -DHDF5_ENABLE_PARALLEL=ON
        -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_ENCODING=ON
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share/hdf5
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/hdf5/data/COPYING ${CURRENT_PACKAGES_DIR}/share/hdf5/copyright)

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/hdf5/hdf5-targets-debug.cmake HDF5_TARGETS_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" HDF5_TARGETS_DEBUG_MODULE "${HDF5_TARGETS_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-targets-debug.cmake "${HDF5_TARGETS_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
