# highfive should be updated together with hdf5

string(REPLACE "." "." hdf5_ref "hdf5_${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  HDFGroup/hdf5
    REF "${hdf5_ref}"
    SHA512 609e129f78c6777a0e64694de8ec638326a616ff9cbd916f310dc6f78435ef67194c5ab59faedda09c85c045c15ebe2ec4ce04fa905d5f74801600e067c27fcc
    HEAD_REF develop
    PATCHES
        default-plugin-dir.diff # avoid absolute path
        libaec-config.diff
        pkgconfig.patch
        win-compile-flags.diff
)

set(HDF5_ALLOW_UNSUPPORTED OFF)
set(unsupported_with_parallel cpp)
set(unsupported_with_threadsafe parallel fortran cpp hl)
foreach(feature IN ITEMS parallel threadsafe)
    if(NOT feature IN_LIST FEATURES)
        continue()
    endif()
    foreach(other IN LISTS unsupported_with_${feature})
        if(other IN_LIST FEATURES)
            message(WARNING "Features '${feature}' and '${other}' are mutually exclusive. Implicitly enabling option HDF5_ALLOW_UNSUPPORTED to unlock the build with both.")
            set(HDF5_ALLOW_UNSUPPORTED ON)
        endif()
    endforeach()
endforeach()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp          HDF5_BUILD_CPP_LIB
        fortran      HDF5_BUILD_FORTRAN
        hl           HDF5_BUILD_HL_LIB
        map          HDF5_ENABLE_MAP_API
        mirror       HDF5_ENABLE_MIRROR_VFD
        parallel     HDF5_ENABLE_PARALLEL
        szip         HDF5_ENABLE_SZIP_SUPPORT
        szip         HDF5_ENABLE_SZIP_ENCODING
        threadsafe   HDF5_ENABLE_THREADSAFE
        tools        HDF5_BUILD_TOOLS
        tools        HDF5_BUILD_UTILS
        zlib         HDF5_ENABLE_ZLIB_SUPPORT
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS -DBUILD_STATIC_EXECS=ON)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND FEATURE_OPTIONS -DBUILD_STATIC_LIBS=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DHDF5_ALLOW_EXTERNAL_SUPPORT=NO
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share/hdf5
        -DHDF_PACKAGE_NAMESPACE:STRING=hdf5::
        -DHDF5_MSVC_NAMING_CONVENTION=OFF
        -DHDF5_ALLOW_UNSUPPORTED=${HDF5_ALLOW_UNSUPPORTED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
foreach(file IN LISTS pc_files)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${file}" " -lhdf5" " -llibhdf5" IGNORE_UNCHANGED)
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${file}" "/msmpi.lib\"" "/msmpi\"" IGNORE_UNCHANGED)
    endif()
endforeach()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake"
    [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/bin"]]
    [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/tools/hdf5"]]
)
if("parallel" IN_LIST FEATURES AND NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake"
        [[..HDF5_PACKAGE_NAME._MPI_C_LIBRARIES    "..VCPKG_IMPORT_PREFIX.(/lib/[^"]*)"]]
        [[${HDF5_PACKAGE_NAME}_MPI_C_LIBRARIES    optimized "${VCPKG_IMPORT_PREFIX}\1" debug "${VCPKG_IMPORT_PREFIX}/debug\1"]]
        REGEX
    )
endif()

set(HDF5_TOOLS "")
if("tools" IN_LIST FEATURES)
    list(APPEND HDF5_TOOLS
        h5perf_serial
        h5clear h5copy
        h5debug h5delete h5diff h5dump
        h5format_convert
        h5import
        h5jam
        h5ls
        h5mkgrp
        h5repack h5repart
        h5stat
        h5unjam
    )

    if ("hl" IN_LIST FEATURES)
        list(APPEND HDF5_TOOLS h5watch)
    endif()

    if ("mirror" IN_LIST FEATURES)
        list(APPEND HDF5_TOOLS mirror_server mirror_server_stop)
    endif()

    if("parallel" IN_LIST FEATURES)
        list(APPEND HDF5_TOOLS ph5diff h5perf)
    endif()
endif()

if(HDF5_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${HDF5_TOOLS} AUTO_CLEAN)
endif()
foreach(script IN ITEMS h5cc h5c++ h5hlcc h5hlc++ h5pcc h5fuse.sh)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${script}")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}" "${CURRENT_INSTALLED_DIR}" "$(dirname \"$0\")/../.." IGNORE_UNCHANGED)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
    endif()
endforeach()
vcpkg_clean_executables_in_bin(FILE_NAMES none)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
if("parallel" IN_LIST FEATURES)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/H5public.h" "#define H5public_H" "#define H5public_H\n#ifndef H5_BUILT_AS_DYNAMIC_LIB\n#define H5_BUILT_AS_DYNAMIC_LIB\n#endif\n")
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/data/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
