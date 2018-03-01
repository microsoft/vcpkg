if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CMake-hdf5-1.10.1/hdf5-1.10.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/CMake-hdf5-1.10.1.zip"
    FILENAME "CMake-hdf5-1.10.1.zip"
    SHA512 0045a6301c6e3479be70f025d8690297ff33b9e6e99ec217a33e9b916d9410fb3f7110b7361fbeaec163c35b8e6bd948ac8d5fdace80930c98c6a0b27c6fd5c4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-szip-config.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-static-libs.patch
        ${CMAKE_CURRENT_LIST_DIR}/link-libraries-private.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISABLE_STATIC_LIBS)

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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DDISABLE_STATIC_LIBS=${DISABLE_STATIC_LIBS}
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_BUILD_TOOLS=OFF
        -DHDF5_BUILD_CPP_LIB=${ENABLE_CPP}
        -DHDF5_ENABLE_PARALLEL=${ENABLE_PARALLEL}
        -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_ENCODING=ON
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share/hdf5
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/hdf5/data/COPYING ${CURRENT_PACKAGES_DIR}/share/hdf5/copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/hdf5)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
