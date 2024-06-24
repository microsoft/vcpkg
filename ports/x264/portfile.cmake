vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF eaa68fad9e5d201d42fde51665f2d137ae96baf0 # 0.164.3107 in pc file, to be updated below
    SHA512 9181b222e7f8bbde4331141ff399e1ef20d3e2e7a8f939b373fbe08df6f3caa99b992afb0e559cc19f78c96f0105b88b2eb4e4b935484e25b2c15da7903d179b
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

function(add_cross_prefix)
  if(configure_env MATCHES "CC=([^\/]*-)gcc$")
      vcpkg_list(APPEND arg_OPTIONS "--cross-prefix=${CMAKE_MATCH_1}")
  endif()
  set(arg_OPTIONS "${arg_OPTIONS}" PARENT_SCOPE)
endfunction()

set(nasm_archs x86 x64)
set(gaspp_archs arm arm64)
if(NOT "asm" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --disable-asm)
elseif(NOT "$ENV{AS}" STREQUAL "")
    # Accept setting from triplet
elseif(VCPKG_TARGET_ARCHITECTURE IN_LIST nasm_archs)
    vcpkg_find_acquire_program(NASM)
    vcpkg_insert_program_into_path("${NASM}")
    set(ENV{AS} "${NASM}")
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

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND OPTIONS --enable-pic)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_CPPFLAGS # Build is not using CPP/CPPFLAGS
    DISABLE_MSVC_WRAPPERS
    LANGUAGES ASM C CXX # Requires NASM to compile
    NO_MSVC_FLAG_ESCAPING # disable warnings about unknown -Xcompiler/-Xlinker flags
    PRE_CONFIGURE_CMAKE_COMMANDS
        add_cross_prefix
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

vcpkg_make_install()

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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
