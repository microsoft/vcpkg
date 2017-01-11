include(vcpkg_common_functions)

# set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/szip-2.1)
# vcpkg_download_distfile(ARCHIVE
#     URLS "https://support.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz"
#     FILENAME "szip-2.1.tar.gz"
#     SHA512 ea91b877bb061fe6c96988a3c4b705e101a6950e34e9be53d6a57455c6a625be0afa60f4a3cfdd09649205b9f8586cc25ea60fe07a8131579acf3826b35fb749
# )
# vcpkg_extract_source_archive(${ARCHIVE})

# NOTE: We use Szip from the HDF5 cmake package dir, because it includes a lot of fixes for the CMake build files

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CMake-hdf5-1.10.0-patch1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://hdf4.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/CMake-hdf5-1.10.0-patch1.zip"
    FILENAME "CMake-hdf5-1.10.0-patch1.zip"
    SHA512 ec2edb43438661323be5998ecf64c4dd537ddc7451e31f89390260d16883e60a1ccc1bf745bcb809af22f2bf7157d50331a33910b8ebf5c59cd50693dfb2ef8f
)
vcpkg_extract_source_archive(${ARCHIVE})
set(ARCHIVE ${SOURCE_PATH}/SZip.tar.gz)
vcpkg_extract_source_archive(${ARCHIVE})
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Szip)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=1
        -DSZIP_INSTALL_DATA_DIR=share/szip/data
        -DSZIP_INSTALL_CMAKE_DIR=share/szip
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/szip/data/COPYING ${CURRENT_PACKAGES_DIR}/share/szip/copyright)

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/szip/szip-targets-debug.cmake SZIP_TARGETS_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" SZIP_TARGETS_DEBUG_MODULE "${SZIP_TARGETS_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/szip/szip-targets-debug.cmake "${SZIP_TARGETS_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
