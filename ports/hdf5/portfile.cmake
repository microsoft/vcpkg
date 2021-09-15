# highfive should be updated together with hdf5

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  HDFGroup/hdf5
    REF hdf5-1_12_1
    SHA512 8a736b6a66bf4ec904a0e0dd9e8e0e791d8a04c996c5ea6b73b7d6f8145c4bfa4ed5c6e4f11740ceb1d1226a333c8242968e604dbdac2b7b561a1bd265423434
    HEAD_REF develop
    PATCHES
        hdf5_config.patch
        szip.patch
        mingw-import-libs.patch
        pkgconfig-requires.patch
)

if ("parallel" IN_LIST FEATURES AND "cpp" IN_LIST FEATURES)
    message(FATAL_ERROR "Feature Parallel and C++ options are mutually exclusive.")
endif()

if ("fortran" IN_LIST FEATURE)
    message(WARNING "Fortran is not yet official supported within VCPKG. Build will most likly fail if ninja 1.10 and a Fortran compiler are not available.")
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
)

file(REMOVE "${SOURCE_PATH}/config/cmake_ext_mod/FindSZIP.cmake")#Outdated; does not find debug szip

if(FEATURES MATCHES "tools" AND VCPKG_CRT_LINKAGE STREQUAL "static")
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
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share
        -DHDF_PACKAGE_NAMESPACE:STRING=hdf5::
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

set(debug_suffix debug)
if(VCPKG_TARGET_IS_WINDOWS)
    set(debug_suffix D)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5.pc")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5.pc"
        "-lhdf5"
        "-lhdf5_${debug_suffix}"
    )
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_hl.pc")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_hl.pc"
        "-lhdf5_hl"
        "-lhdf5_hl_${debug_suffix}"
    )
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_cpp.pc")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_cpp.pc"
        "-lhdf5_cpp"
        "-lhdf5_cpp_${debug_suffix}"
    )
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_cpp.pc"
        "Requires.private: hdf5"
        ""
    )
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/hdf5_cpp.pc")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/hdf5_cpp.pc"
        "Requires.private: hdf5"
        ""
    )
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_hl_cpp.pc")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hdf5_hl_cpp.pc"
        "-lhdf5_hl_cpp"
        "-lhdf5_hl_cpp_${debug_suffix}"
    )
endif()
set(PKG_FILES hdf5 hdf5_hl hdf5_cpp hdf5_hl_cpp)
foreach(PC_FILE IN LISTS PKG_FILES)
    set(SUBPATHS "/debug/lib/pkgconfig" "/lib/pkgconfig")
    foreach(SUBPATH IN LISTS SUBPATHS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}${SUBPATH}/${PC_FILE}.pc")
            file(RENAME "${CURRENT_PACKAGES_DIR}${SUBPATH}/${PC_FILE}.pc" "${CURRENT_PACKAGES_DIR}${SUBPATH}/${PC_FILE}.pc")
        endif()
    endforeach()
endforeach()
#vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/mirror_server${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mirror_server${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/mirror_server_stop${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mirror_server_stop${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

file(READ "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" contents)
string(REPLACE [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/bin"]] [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/tools/hdf5"]] contents ${contents})
file(WRITE "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" ${contents})

if(FEATURES MATCHES "tools")
    set(TOOLS h5cc h5hlcc h5c++ h5hlc++ h5copy h5diff h5dump h5ls h5stat gif2h5 h52gif h5clear h5debug h5format_convert h5jam h5unjam h5ls h5mkgrp h5repack h5repart h5watch ph5diff h5import)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(TOOL_SUFFIXES "-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX};${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    else()
        set(TOOL_SUFFIXES "-static${VCPKG_TARGET_EXECUTABLE_SUFFIX};${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    endif()

    foreach(tool IN LISTS TOOLS)
        foreach(suffix IN LISTS TOOL_SUFFIXES)
            if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
                file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
            endif()
            if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
                file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}"
                     DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
                file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
            endif()
        endforeach()
    endforeach()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/data/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
