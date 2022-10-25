vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF baee400fa9ced6f5481a728138fed6e867b0ff7f # 0.164.3095 in pc file, to be updated below
    SHA512 3c7147457cbe0fea20cf3ed8cf7bbdca9ac15060cf86f81b9b5b54b018f922964e91b3c38962c81fedef92bc5b14489e04d0966d03d2b7a85b4dabab6ad816a2
    HEAD_REF stable
    PATCHES
        uwp-cflags.patch
        parallel-install.patch
        allow-clang-cl.patch
        configure-as.patch # Ignore ':' from `vcpkg_configure_make`
)

vcpkg_replace_string("${SOURCE_PATH}/configure" [[/bin/bash]] [[/usr/bin/env bash]])

# Note on x264 versioning:
# The pc file exports "0.164.<N>" where is the number of commits.
# This must be fixed here because vcpkg uses a GH tarball instead of cloning the source.
# (The binary releases on https://artifacts.videolan.org/x264/ are named x264-r<N>-<COMMIT>.)
vcpkg_replace_string("${SOURCE_PATH}/version.sh" [[ver="x"]] [[ver="3095"]])

# Ensure that 'ENV{PATH}' leads to tool 'name' exactly at 'filepath'.
function(ensure_tool_in_path name filepath)
    unset(program_found CACHE)
    find_program(program_found "${name}" PATHS ENV PATH NO_DEFAULT_PATH NO_CACHE)
    if(NOT filepath STREQUAL program_found)
        cmake_path(GET filepath PARENT_PATH parent_path)
        vcpkg_add_to_path(PREPEND "${parent_path}")
    endif()
endfunction()

# Ensure that parent-scope variable 'var' doesn't contain a space,
# updating 'ENV{PATH}' and 'var' if needed.
function(transform_path_no_space var)
    set(path "${${var}}")
    if(path MATCHES " ")
        cmake_path(GET path FILENAME program_name)
        set("${var}" "${program_name}" PARENT_SCOPE)
        ensure_tool_in_path("${program_name}" "${path}")
    endif()
endfunction()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

transform_path_no_space(VCPKG_DETECTED_CMAKE_C_COMPILER)
set(ENV{CC} "${VCPKG_DETECTED_CMAKE_C_COMPILER}")

vcpkg_list(SET OPTIONS)
if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "([^\/]*-)gcc$")
    vcpkg_list(APPEND OPTIONS "--cross-prefix=${CMAKE_MATCH_1}")
endif()

vcpkg_list(SET EXTRA_ARGS)
set(nasm_archs x86 x64)
set(gaspp_archs arm arm64)
if(NOT "asm" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --disable-asm)
elseif(NOT "$ENV{AS}" STREQUAL "")
    # Accept setting from triplet
elseif(VCPKG_TARGET_ARCHITECTURE IN_LIST nasm_archs)
    vcpkg_find_acquire_program(NASM)
    transform_path_no_space(NASM)
    list(APPEND EXTRA_ARGS CONFIGURE_ENVIRONMENT_VARIABLES AS)
    set(AS "${NASM}") # for CONFIGURE_ENVIRONMENT_VARIABLES
    set(ENV{AS} "${NASM}") # for non-WIN32
elseif(VCPKG_TARGET_ARCHITECTURE IN_LIST gaspp_archs AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_HOST_IS_WINDOWS)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    list(FILTER GASPREPROCESSOR INCLUDE REGEX gas-preprocessor)
    file(INSTALL "${GASPREPROCESSOR}" DESTINATION "${SOURCE_PATH}/tools" RENAME "gas-preprocessor.pl")
endif()

vcpkg_list(SET OPTIONS_RELEASE)
if("tool" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS_RELEASE --enable-cli)
else()
    vcpkg_list(APPEND OPTIONS_RELEASE --disable-cli)
endif()

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS --extra-cflags=-D_WIN32_WINNT=0x0A00)
endif()

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND OPTIONS --enable-pic)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    DETERMINE_BUILD_TRIPLET
    ${EXTRA_ARGS}
    OPTIONS
        ${OPTIONS}
        --disable-lavf
        --disable-swscale
        --disable-avs
        --disable-ffms
        --disable-gpac
        --disable-lsmash
        --disable-bashcompletion
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
        --enable-strip
    OPTIONS_DEBUG
        --enable-debug
        --disable-cli
)

vcpkg_install_make()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES x264 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x264.pc" "-lx264" "-llibx264")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x264.pc" "-lx264" "-llibx264")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libx264.dll.lib" "${CURRENT_PACKAGES_DIR}/lib/libx264.lib")
    if (NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libx264.dll.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/libx264.lib")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/x264.h" "#ifdef X264_API_IMPORTS" "#if 1")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/x264.h" "defined(U_STATIC_IMPLEMENTATION)" "1")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
