# highfive should be updated together with hdf5

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  HDFGroup/hdf5
    REF hdf5-1_12_2
    SHA512 8f110e035a9bd5b07687b30fb944ed72e5b6a6e0ea74ee650250f40f0d4ff81e304366a76129a50a2d37c7f4c59a57356d0d9eed18db6cb90e924c62273d17a4
    HEAD_REF develop
    PATCHES
        hdf5_config.patch
        szip.patch
        pkgconfig-requires.patch
        pkgconfig-link-order.patch
)

set(ALLOW_UNSUPPORTED OFF)
if ("parallel" IN_LIST FEATURES AND "cpp" IN_LIST FEATURES)
    message(WARNING "Feature 'Parallel' and 'cpp' are mutually exclusive, enable feature ALLOW_UNSUPPORTED automatically to enable them both.")
    set(ALLOW_UNSUPPORTED ON)
endif()

if ("threadsafe" IN_LIST FEATURES AND
    ("parallel" IN_LIST FEATURES
     OR "fortran" IN_LIST FEATURES
     OR "cpp" IN_LIST FEATURES)
     )
    message(WARNING "Feture 'threadsafe' and other features are mutually exclusive, enable feature ALLOW_UNSUPPORTED automatically to enable them both.")
    set(ALLOW_UNSUPPORTED ON)
endif()

if ("fortran" IN_LIST FEATURE)
    message(WARNING "Feature 'fortran' is not yet official supported within VCPKG. Build will most likly fail if ninja 1.10 and a Fortran compiler are not available.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        parallel     HDF5_ENABLE_PARALLEL
        tools        HDF5_BUILD_TOOLS
        cpp          HDF5_BUILD_CPP_LIB
        szip         HDF5_ENABLE_SZIP_SUPPORT
        szip         HDF5_ENABLE_SZIP_ENCODING
        zlib         HDF5_ENABLE_Z_LIB_SUPPORT
        fortran      HDF5_BUILD_FORTRAN
        threadsafe   HDF5_ENABLE_THREADSAFE
        utils        HDF5_BUILD_UTILS
)

file(REMOVE "${SOURCE_PATH}/config/cmake_ext_mod/FindSZIP.cmake")#Outdated; does not find debug szip

if("tools" IN_LIST FEATURES AND VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS -DBUILD_STATIC_EXECS=ON)
endif()

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS
                    -DBUILD_STATIC_LIBS=OFF
                    -DONLY_SHARED_LIBS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share/hdf5
        -DHDF_PACKAGE_NAMESPACE:STRING=hdf5::
        -DHDF5_MSVC_NAMING_CONVENTION=OFF
        -DSZIP_USE_EXTERNAL=ON
        -DALLOW_UNSUPPORTED=${ALLOW_UNSUPPORTED}
    OPTIONS_RELEASE
        -DCMAKE_DEBUG_POSTFIX= # For lib name in pkgconfig files
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

set(debug_suffix debug)
if(VCPKG_TARGET_IS_WINDOWS)
    set(debug_suffix D)
endif()

vcpkg_fixup_pkgconfig()

file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
foreach(file IN LISTS pc_files)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${file}" " -lhdf5" " -llibhdf5")
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${file}" "/msmpi.lib\"" "/msmpi\"")
    endif()
endforeach()

file(READ "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" contents)
string(REPLACE [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/bin"]]
               [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/tools/hdf5"]]
               contents ${contents}
)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" ${contents})

set(HDF5_TOOLS "")
if("tools" IN_LIST FEATURES)
    list(APPEND HDF5_TOOLS h5copy h5diff h5dump h5ls h5stat gif2h5 h52gif h5clear h5debug
        h5format_convert h5jam h5unjam h5mkgrp h5repack h5repart h5watch h5import
    )

    if("parallel" IN_LIST FEATURES)
        list(APPEND HDF5_TOOLS ph5diff)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(TRANSFORM HDF5_TOOLS REPLACE  "^(.+)$" "\\1-shared")
    endif()

    if(NOT VCPKG_TARGET_IS_WINDOWS)
        list(APPEND HDF5_TOOLS h5cc h5hlcc)
        if("cpp" IN_LIST FEATURES)
            list(APPEND HDF5_TOOLS h5c++ h5hlc++)
        endif()
    endif()

    if("parallel" IN_LIST FEATURES)
        list(APPEND HDF5_TOOLS h5perf )
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            list(APPEND HDF5_TOOLS h5pcc)
        endif()
    else()
        list(APPEND HDF5_TOOLS h5perf_serial)
    endif()
endif()

if ("utils" IN_LIST FEATURES)
    list(APPEND HDF5_TOOLS mirror_server mirror_server_stop)
endif()

if(HDF5_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${HDF5_TOOLS} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Clean up
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/data/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
