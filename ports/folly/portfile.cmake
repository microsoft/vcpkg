if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  message(FATAL_ERROR "Folly only supports the x64 architecture.")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2021.06.14.00
    SHA512 aee5adc1a44d9b193f3f41b5fc9fa7575c677d8bf27ed3a3b612a2fbe53505f82481ce78f13fb41ae3ca81ca25446426fbdfdc578f503f919b4af5abe56ad71c
    HEAD_REF master
    PATCHES
        reorder-glog-gflags.patch
        disable-non-underscore-posix-names.patch
        boost-1.70.patch
        fix-windows-minmax.patch
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
        -DCMAKE_INSTALL_DIR=share/folly
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

# Release folly-targets.cmake does not link to the right libraries in debug mode.
# We substitute with generator expressions so that the right libraries are linked for debug and release.
set(FOLLY_TARGETS_CMAKE "${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake")
FILE(READ ${FOLLY_TARGETS_CMAKE} _contents)
string(REPLACE "\${_IMPORT_PREFIX}/lib/zlib.lib" "ZLIB::ZLIB" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
string(REPLACE "-vc140-mt.lib" "-vc140-mt\$<\$<CONFIG:DEBUG>:-gd>.lib" _contents "${_contents}")
FILE(WRITE ${FOLLY_TARGETS_CMAKE} "${_contents}")
FILE(READ ${CURRENT_PACKAGES_DIR}/share/folly/folly-config.cmake _contents)
FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/folly/folly-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(glog CONFIG)
find_dependency(gflags CONFIG REQUIRED)
find_dependency(ZLIB)
${_contents}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
