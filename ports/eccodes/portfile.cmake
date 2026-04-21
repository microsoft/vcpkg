vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ecmwf/eccodes
    REF "${VERSION}"
    SHA512 14b75d100fbf4ee68b62406051b49b341567a346477f36c88a7fa59e5f1b7d5b0886d82c222ebe8b66809dcdb4a3bebe96da418694ac759e5c18ad904467624c
    HEAD_REF develop
    PATCHES
        use-system-ecbuild.patch
)

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT)
    set(ENV{PATH} "${MSYS_ROOT}/usr/bin;$ENV{PATH}")
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
    set(ECCODES_REPLACE_TPL_ABSOLUTE_PATHS OFF)
else()
    set(ECCODES_REPLACE_TPL_ABSOLUTE_PATHS ON)
endif()

set(ECCODES_OPTIONS
    -DBUILD_TESTING=OFF
    -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
    -DCMAKE_DISABLE_FIND_PACKAGE_Jasper=ON
    -DENABLE_MEMFS=ON
    -DENABLE_INSTALL_ECCODES_DEFINITIONS=OFF
    -DENABLE_INSTALL_ECCODES_SAMPLES=OFF
    -DENABLE_EXTRA_TESTS=OFF
    -DENABLE_JPG=ON
    -DENABLE_JPG_LIBJASPER=OFF
    -DENABLE_JPG_LIBOPENJPEG=ON
    -DENABLE_AEC=OFF
    -DENABLE_FORTRAN=OFF
    -DENABLE_NETCDF=OFF
    -DENABLE_PNG=OFF
    -DREPLACE_TPL_ABSOLUTE_PATHS=${ECCODES_REPLACE_TPL_ABSOLUTE_PATHS}
)

if("aec" IN_LIST FEATURES)
    list(APPEND ECCODES_OPTIONS -DENABLE_AEC=ON)
else()
    list(APPEND ECCODES_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_libaec=ON)
endif()

if("fortran" IN_LIST FEATURES)
    list(APPEND ECCODES_OPTIONS -DENABLE_FORTRAN=ON)
endif()

if("netcdf" IN_LIST FEATURES)
    list(APPEND ECCODES_OPTIONS -DENABLE_NETCDF=ON)
endif()

if("png" IN_LIST FEATURES)
    list(APPEND ECCODES_OPTIONS -DENABLE_PNG=ON)
endif()

# ecCodes uses try_run() for IEEE endianness probes. Those cannot execute when
# vcpkg cross-compiles arm64-windows from an x64 Windows host, so preseed the
# known little-endian results for that specific case.
if(VCPKG_CROSSCOMPILING AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND ECCODES_OPTIONS
        -DIEEE_LE_EXITCODE=0
        -DIEEE_BE_EXITCODE=1
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${ECCODES_OPTIONS}
        -Decbuild_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/ecbuild
        -DPERL_EXECUTABLE=${PERL}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/eccodes)
vcpkg_fixup_pkgconfig()

function(eccodes_move_tools_from_bin bin_dir tools_dir)
    if(NOT EXISTS "${bin_dir}")
        return()
    endif()

    file(GLOB _entries "${bin_dir}/*")
    foreach(_entry IN LISTS _entries)
        if(IS_DIRECTORY "${_entry}")
            continue()
        endif()

        get_filename_component(_name "${_entry}" NAME)
        if(_name MATCHES [[\.(dll|pdb|so(\..*)?|dylib)$]])
            continue()
        endif()

        file(MAKE_DIRECTORY "${tools_dir}")
        file(RENAME "${_entry}" "${tools_dir}/${_name}")
    endforeach()
endfunction()

eccodes_move_tools_from_bin("${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
eccodes_move_tools_from_bin("${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

function(eccodes_replace_prefix_in_file file_path from to)
    if(NOT EXISTS "${file_path}")
        return()
    endif()

    file(READ "${file_path}" _content)
    set(_updated "${_content}")
    string(REPLACE "${from}" "${to}" _updated "${_updated}")
    if(NOT _updated STREQUAL _content)
        file(WRITE "${file_path}" "${_updated}")
    endif()
endfunction()

function(eccodes_scrub_vcpkg_paths file_path)
    if(NOT EXISTS "${file_path}")
        return()
    endif()

    set(_prefix_pairs
        "${CURRENT_PACKAGES_DIR}" "@VCPKG_PACKAGES_DIR@"
        "${CURRENT_INSTALLED_DIR}" "@VCPKG_INSTALLED_DIR@"
        "${CURRENT_HOST_INSTALLED_DIR}" "@VCPKG_HOST_INSTALLED_DIR@"
        "${CURRENT_BUILDTREES_DIR}" "@VCPKG_BUILDTREES_DIR@"
        "${DOWNLOADS}" "@VCPKG_DOWNLOADS_DIR@"
    )

    list(LENGTH _prefix_pairs _pair_count)
    math(EXPR _last_index "${_pair_count} - 1")
    foreach(_index RANGE 0 ${_last_index} 2)
        math(EXPR _next_index "${_index} + 1")
        list(GET _prefix_pairs ${_index} _from)
        list(GET _prefix_pairs ${_next_index} _to)

        file(TO_CMAKE_PATH "${_from}" _from_cmake)
        string(REPLACE "/" "\\" _from_native "${_from_cmake}")

        eccodes_replace_prefix_in_file("${file_path}" "${_from_cmake}" "${_to}")
        eccodes_replace_prefix_in_file("${file_path}" "${_from_native}" "${_to}")
    endforeach()
endfunction()

set(_eccodes_files_to_scrub
    "${CURRENT_PACKAGES_DIR}/include/eccodes_config.h"
    "${CURRENT_PACKAGES_DIR}/include/eccodes_ecbuild_config.h"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/codes_config"
)

foreach(_file IN LISTS _eccodes_files_to_scrub)
    eccodes_scrub_vcpkg_paths("${_file}")
endforeach()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
