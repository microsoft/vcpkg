if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CMake-hdf5-1.10.5/hdf5-1.10.5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/CMake-hdf5-1.10.5.zip"
    FILENAME "CMake-hdf5-1.10.5.zip"
    SHA512 d799ae987d00f493a0a0a2c9f61beaa1a5a1dfd18509e310bd7eb2b3bb411d337fbff5f7f8cc58d0708ba2542d8831fec1ae1adc0f845b3d3579809ec7edc4e0
)
vcpkg_extract_source_archive(${ARCHIVE})

if ("parallel" IN_LIST FEATURES)
    set(ENABLE_PARALLEL ON)
else()
    set(ENABLE_PARALLEL OFF)
endif()

if ("cpp" IN_LIST FEATURES)
    set(ENABLE_CPP ON)
else()
    set(ENABLE_CPP OFF)
endif()

#Note: HDF5 Builds by default static as well as shared libraries set BUILD_SHARED_LIBS to OFF to only get static libraries
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_BUILD_TOOLS=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DHDF5_BUILD_CPP_LIB=${ENABLE_CPP}
        -DHDF5_ENABLE_PARALLEL=${ENABLE_PARALLEL}
        -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_ENCODING=ON
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share/
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/hdf5/data/COPYING ${CURRENT_PACKAGES_DIR}/share/hdf5/copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/hdf5)

# Fix static szip link
file(READ ${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-targets.cmake HDF5_TARGETS_DATA)
# Fix szip linkage
#STRING(REPLACE LINK_ONLY:szip-static [[LINK_ONLY:${_IMPORT_PREFIX}/$<$<CONFIG:Debug>:debug/>lib/libszip$<$<CONFIG:Debug>:_D>.lib]] HDF5_TARGETS_NEW "${HDF5_TARGETS_DATA}")
# Fix zlib linkage
STRING(REPLACE "lib/zlib" [[$<$<CONFIG:Debug>:debug/>lib/zlib$<$<CONFIG:Debug>:d>]] HDF5_TARGETS_NEW "${HDF5_TARGETS_DATA}")

#write everything to file
file(WRITE ${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-targets.cmake "${HDF5_TARGETS_NEW}")


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
