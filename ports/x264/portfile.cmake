# The latest ref in branch stable
set(ref 31e19f92f00c7003fa115047ce50978bc98c3a0d)

# Note on x264 versioning:
# The pc file exports "0.164.<N>" where is the number of commits.
# The binary releases on https://artifacts.videolan.org/x264/ are named x264-r<N>-<COMMIT>.
# With a git clone, this can be determined by running `versions.sh`.
# With vcpkg_from_gitlab, we modify `versions.sh` accordingly.
# For --editable mode, use configured patch instead of vcpkg_replace_string.
string(REGEX MATCH "^......." short_ref "${ref}")
string(REGEX MATCH "[0-9]+\$" revision "${VERSION}")
configure_file("${CURRENT_PORT_DIR}/version.diff.in" "${CURRENT_BUILDTREES_DIR}/src/version-${VERSION}.diff" @ONLY)

vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/x264
    REF "${ref}"
    SHA512 707ff486677a1b5502d6d8faa588e7a03b0dee45491c5cba89341be4be23d3f2e48272c3b11d54cfc7be1b8bf4a3dfc3c3bb6d9643a6b5a2ed77539c85ecf294
    HEAD_REF master
    PATCHES
        "${CURRENT_BUILDTREES_DIR}/src/version-${VERSION}.diff"
        uwp-cflags.patch
        parallel-install.patch
        allow-clang-cl.patch
        configure.patch
)

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

if("chroma-format-all" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --chroma-format=all)
endif()

if(NOT "gpl" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --disable-gpl)
endif()

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS --extra-cflags=-D_WIN32_WINNT=0x0A00)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_ADDITIONAL_PATHS
    DETERMINE_BUILD_TRIPLET
    ${EXTRA_ARGS}
    OPTIONS
        ${OPTIONS}
        --enable-pic
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/x264.h" "defined(U_STATIC_IMPLEMENTATION)" "1" IGNORE_UNCHANGED)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
