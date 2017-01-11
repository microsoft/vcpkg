# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hdf5-1.8.18)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar.bz2"
    FILENAME "hdf5-1.8.18.tar.bz2"
    SHA512 01f6d14bdd3be2ced9c63cc9e1820cd7ea11db649ff9f3a3055c18c4b0fffe777fd23baad536e3bce31c4d76fe17db64a3972762e1bb4d232927c1ca140e72b2
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=1
        -DBUILD_TESTING=OFF
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
