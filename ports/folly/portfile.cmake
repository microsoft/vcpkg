if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  message(FATAL_ERROR "Folly only supports the x64 architecture.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2018.06.25.00
    SHA512 4961c02326005bcd82200f9e1b0b3d00c9afb60ed6dacdcc4f191095670122ea2fe33e91b3d638dc55664636af7c1b4f75b5f5c0c5cdfb0e8ca310ab28aa5ca3
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/find-gflags.patch
		${CMAKE_CURRENT_LIST_DIR}/fixC2338.patch
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/FindLZ4.cmake
    ${CMAKE_CURRENT_LIST_DIR}/FindSnappy.cmake
    DESTINATION ${SOURCE_PATH}/CMake/
)
file(REMOVE ${SOURCE_PATH}/CMake/FindGFlags.cmake)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(MSVC_USE_STATIC_RUNTIME ON)
else()
    set(MSVC_USE_STATIC_RUNTIME OFF)
endif()

set(FEATURE_OPTIONS)

macro(feature FEATURENAME PACKAGENAME)
    if("${FEATURENAME}" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_${PACKAGENAME}=OFF)
    else()
        list(APPEND FEATURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_${PACKAGENAME}=ON)
    endif()
endmacro()

feature(zlib ZLIB)
feature(bzip2 BZip2)
feature(lzma LibLZMA)
feature(lz4 LZ4)
feature(zstd Zstd)
feature(snappy Snappy)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
        -DCMAKE_DISABLE_FIND_PACKAGE_LibDwarf=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libiberty=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_LibAIO=ON
        -DLIBAIO_FOUND=OFF
        -DLIBURCU_FOUND=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_LibURCU=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/folly)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/folly)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/folly/LICENSE ${CURRENT_PACKAGES_DIR}/share/folly/copyright)
