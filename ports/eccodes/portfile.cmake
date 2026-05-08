vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/eccodes
    REF "${VERSION}"
    SHA512 8d6d1dfa366f41bf1c7fe129540a02183a9e117e26793b9e17b102cde1bd2277ece9c9b7958daf88a4a6cf21997f55793d8a52b5b62c827b7a4a4b2ac1dd3344
    HEAD_REF develop
    PATCHES
        fix-netcdf-linkage.patch
)

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT)
    vcpkg_add_to_path(PREPEND "${MSYS_ROOT}/usr/bin")
endif()

vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH "${PYTHON3}" DIRECTORY)
get_filename_component(PYTHON3_ROOT "${PYTHON3_PATH}" DIRECTORY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        aec ENABLE_AEC
        fortran ENABLE_FORTRAN
        netcdf ENABLE_NETCDF
        png ENABLE_PNG
    INVERTED_FEATURES
        netcdf CMAKE_DISABLE_FIND_PACKAGE_netCDF
        png CMAKE_DISABLE_FIND_PACKAGE_PNG
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(ECCODES_ENABLE_THREADS OFF)
    set(ECCODES_ENABLE_OMP_THREADS ON)
else()
    set(ECCODES_ENABLE_THREADS ON)
    set(ECCODES_ENABLE_OMP_THREADS OFF)
endif()

set(ECCODES_OPTIONS
    ${FEATURE_OPTIONS}
    -DBUILD_TESTING=OFF
    -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
    -DVCPKG_LOCK_FIND_PACKAGE_Jasper=OFF
    -DVCPKG_LOCK_FIND_PACKAGE_OpenMP=OFF
    -DENABLE_MEMFS=ON
    -DENABLE_INSTALL_ECCODES_DEFINITIONS=ON
    -DENABLE_INSTALL_ECCODES_SAMPLES=ON
    -DENABLE_EXTRA_TESTS=OFF
    -DENABLE_JPG=ON
    -DENABLE_JPG_LIBJASPER=OFF
    -DENABLE_JPG_LIBOPENJPEG=ON
    -DREPLACE_TPL_ABSOLUTE_PATHS=OFF
    -DENABLE_ECCODES_THREADS=${ECCODES_ENABLE_THREADS}
    -DENABLE_ECCODES_OMP_THREADS=${ECCODES_ENABLE_OMP_THREADS}
)

if(NOT "aec" IN_LIST FEATURES AND NOT "netcdf" IN_LIST FEATURES)
    list(APPEND ECCODES_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_libaec=ON)
endif()

# ecCodes uses try_run() for IEEE endianness probes. Those cannot execute when
# vcpkg cross-compiles, so preseed the known little-endian results.
if(VCPKG_CROSSCOMPILING)
    list(APPEND ECCODES_OPTIONS
        -DIEEE_LE_EXITCODE=0
        -DIEEE_BE_EXITCODE=1
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${ECCODES_OPTIONS}
        -DCMAKE_REQUIRE_FIND_PACKAGE_ecbuild=ON
        -Decbuild_ROOT=${CURRENT_HOST_INSTALLED_DIR}
        -DPERL_EXECUTABLE=${PERL}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DPython_EXECUTABLE=${PYTHON3}
        -DPython3_EXECUTABLE=${PYTHON3}
        -DPython_ROOT_DIR=${PYTHON3_ROOT}
        -DPython3_ROOT_DIR=${PYTHON3_ROOT}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/eccodes)

# vcpkg_cmake_config_fixup moves upstream's config files from lib/cmake/eccodes
# to share/eccodes. The upstream config still validates eccodes_CMAKE_DIR
# against the original lib/cmake/eccodes path, which no longer exists after
# fixup. Keep it pointing at the moved vcpkg config directory.
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/eccodes-config.cmake"
    [[${PACKAGE_PREFIX_DIR}/lib/cmake/eccodes]]
    [[${PACKAGE_PREFIX_DIR}/share/eccodes]]
)

vcpkg_fixup_pkgconfig()

set(_eccodes_tool_names
    codes_bufr_filter
    codes_count
    codes_export_resource
    codes_info
    codes_parser
    codes_split_file
    bufr_compare
    bufr_copy
    bufr_count
    bufr_dump
    bufr_get
    bufr_index_build
    bufr_ls
    bufr_set
    grib2ppm
    grib_compare
    grib_copy
    grib_count
    grib_dump
    grib_filter
    grib_get
    grib_get_data
    grib_histogram
    grib_index_build
    grib_ls
    grib_set
    gts_compare
    gts_copy
    gts_count
    gts_dump
    gts_filter
    gts_get
    gts_ls
)

if("netcdf" IN_LIST FEATURES)
    list(APPEND _eccodes_tool_names grib_to_netcdf)
endif()

foreach(_script IN ITEMS codes_config bufr_compare_dir bufr_filter)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_script}")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(RENAME
            "${CURRENT_PACKAGES_DIR}/bin/${_script}"
            "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_script}"
        )
    endif()

    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${_script}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${_script}")
    endif()
endforeach()

vcpkg_copy_tools(
    TOOL_NAMES ${_eccodes_tool_names}
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/definitions/metar/stations"
)

set(_eccodes_files_to_scrub
    "${CURRENT_PACKAGES_DIR}/include/eccodes_config.h"
    "${CURRENT_PACKAGES_DIR}/include/eccodes_ecbuild_config.h"
)

file(GLOB_RECURSE _eccodes_codes_config_files
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/*codes_config"
)
list(APPEND _eccodes_files_to_scrub ${_eccodes_codes_config_files})
list(REMOVE_DUPLICATES _eccodes_files_to_scrub)

set(_eccodes_prefix_pairs
    "${CURRENT_PACKAGES_DIR}" "@VCPKG_PACKAGES_DIR@"
    "${CURRENT_INSTALLED_DIR}" "@VCPKG_INSTALLED_DIR@"
    "${CURRENT_HOST_INSTALLED_DIR}" "@VCPKG_HOST_INSTALLED_DIR@"
    "${CURRENT_BUILDTREES_DIR}" "@VCPKG_BUILDTREES_DIR@"
    "${DOWNLOADS}" "@VCPKG_DOWNLOADS_DIR@"
)

foreach(_file IN LISTS _eccodes_files_to_scrub)
    if(EXISTS "${_file}")
        list(LENGTH _eccodes_prefix_pairs _eccodes_prefix_pair_count)
        math(EXPR _eccodes_prefix_last_index "${_eccodes_prefix_pair_count} - 1")
        foreach(_index RANGE 0 ${_eccodes_prefix_last_index} 2)
            math(EXPR _next_index "${_index} + 1")
            list(GET _eccodes_prefix_pairs ${_index} _from)
            list(GET _eccodes_prefix_pairs ${_next_index} _to)

            file(TO_CMAKE_PATH "${_from}" _from_cmake)
            string(REPLACE "/" "\\" _from_native "${_from_cmake}")
            vcpkg_replace_string("${_file}" "${_from_cmake}" "${_to}" IGNORE_UNCHANGED)
            vcpkg_replace_string("${_file}" "${_from_native}" "${_to}" IGNORE_UNCHANGED)
        endforeach()
    endif()
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
