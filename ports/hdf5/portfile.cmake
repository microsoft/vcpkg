if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CMake-hdf5-1.10.4/hdf5-1.10.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.4/src/CMake-hdf5-1.10.4.zip"
    FILENAME "CMake-hdf5-1.10.4.zip"
    SHA512 cd40b98c60951907094ec2a5a662325e50ea806d9411b3d3654649b5f3e471fe032e7af0d0948d3da6f902707e9ef53579747b6491785eb63dafa1748288b028
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

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/hdf5
    @ONLY
)

# Fix static szip link
file(READ ${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-targets.cmake HDF5_TARGETS_DATA)
STRING(REPLACE LINK_ONLY:szip-static [[LINK_ONLY:${_IMPORT_PREFIX}/lib/libszip.lib]] HDF5_TARGETS_NEW "${HDF5_TARGETS_DATA}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-targets.cmake "${HDF5_TARGETS_NEW}")


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
