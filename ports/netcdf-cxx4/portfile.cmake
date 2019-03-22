# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if(${VCPKG_LIBRARY_LINKAGE} MATCHES "static")
    set(HDF5_USE_STATIC_LIBRARIES ON)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: DLLs not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/netcdf-cxx4-4.3.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Unidata/netcdf-cxx4/archive/v4.3.0.zip"
    FILENAME "netcdf-cxx4-4.3.0.zip"
    SHA512 c0ae933446c5bb019ab90c097787cefe15a0161b6b768e0251e9e0b21c92ca8d42d98babcbe07b81b8db08cd1e9fba7befb853611a76debfdfba0aee4fb4b0bc
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/install-destination.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DNCXX_ENABLE_TESTS=OFF
        -DCMAKE_INSTALL_CMAKECONFIGDIR=share/netCDFCxx
        -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4)
file(
    RENAME
        ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4/COPYRIGHT
        ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4/copyright
)
