if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "x86" "arm" "arm64")
else()
    vcpkg_fail_port_install(ON_ARCH "x86" "arm")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2021.10.11.00
    SHA512 9e97e4e5588a1dce756a4cfb0f86abd0d8bb2ccf9a2f95944a92ba1f6ba6cab6eb6a857598a5851eff2da0c412d9721e9ebf6933b76cbbfac5dca5fbc901e7e6
    HEAD_REF main
    PATCHES
        reorder-glog-gflags.patch
        disable-non-underscore-posix-names.patch
        boost-1.70.patch
        fix-windows-minmax.patch
)

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/FindLZ4.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/FindSnappy.cmake"
    DESTINATION "${SOURCE_PATH}/CMake/"
)
file(REMOVE "${SOURCE_PATH}/CMake/FindGFlags.cmake")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_STATIC_RUNTIME)

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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

vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

# Release folly-targets.cmake does not link to the right libraries in debug mode.
# We substitute with generator expressions so that the right libraries are linked for debug and release.
set(FOLLY_TARGETS_CMAKE "${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake")
FILE(READ ${FOLLY_TARGETS_CMAKE} _contents)
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/zlib.lib" "ZLIB::ZLIB" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "-vc140-mt.lib" "-vc140-mt\$<\$<CONFIG:DEBUG>:-gd>.lib" _contents "${_contents}")
FILE(WRITE ${FOLLY_TARGETS_CMAKE} "${_contents}")
FILE(READ ${CURRENT_PACKAGES_DIR}/share/folly/folly-config.cmake _contents)
FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/folly/folly-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(glog CONFIG)
find_dependency(gflags CONFIG REQUIRED)
find_dependency(ZLIB)
${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
