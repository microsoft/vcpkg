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
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2019.01.28.00
    SHA512 cdd32d863bd98b31332fbcb25a548407857ffd8e611fb5d243821f43fcf240cb796fb4520dddec5537f398c10492e1ecb03de22f7ec0384b98411e9906f40d09
    HEAD_REF master
    PATCHES
        find-gflags.patch
        no-werror.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH share/folly)

# Release folly-targets.cmake does not link to the right libraries in debug mode.
# We substitute with generator expressions so that the right libraries are linked for debug and release.
set(FOLLY_TARGETS_CMAKE "${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake")
FILE(READ ${FOLLY_TARGETS_CMAKE} _contents)
STRING(REPLACE 
[[
"Threads::Threads;Iphlpapi.lib;Ws2_32.lib;${_IMPORT_PREFIX}/lib/boost_context-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_chrono-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_date_time-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_filesystem-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_program_options-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_regex-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_system-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_thread-vc140-mt.lib;${_IMPORT_PREFIX}/lib/boost_atomic-vc140-mt.lib;${_IMPORT_PREFIX}/lib/double-conversion.lib;${_IMPORT_PREFIX}/lib/ssleay32.lib;${_IMPORT_PREFIX}/lib/libeay32.lib;${_IMPORT_PREFIX}/lib/zlib.lib;gflags;glog::glog;event"
]]
[[
"Threads::Threads;Iphlpapi.lib;Ws2_32.lib;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_context-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_context-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_chrono-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_chrono-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_date_time-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_date_time-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_filesystem-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_filesystem-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_program_options-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_program_options-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_regex-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_regex-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_system-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_system-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_thread-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_thread-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/boost_atomic-vc140-mt.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/boost_atomic-vc140-mt-gd.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/double-conversion.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/double-conversion.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/ssleay32.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/ssleay32.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/libeay32.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/libeay32.lib>;\$<\$<NOT:\$<CONFIG:DEBUG>>:${_IMPORT_PREFIX}/lib/zlib.lib>;\$<\$<CONFIG:DEBUG>:${_IMPORT_PREFIX}/debug/lib/zlibd.lib>;gflags;glog::glog;event"
]]
    _contents "${_contents}")
FILE(WRITE ${FOLLY_TARGETS_CMAKE} "${_contents}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/folly)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/folly/LICENSE ${CURRENT_PACKAGES_DIR}/share/folly/copyright)
