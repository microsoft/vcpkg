vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF 5db6aa6cab1b146e07b60cc1736a01f21da01154
    SHA512 d2cdd40d195fd6507abacc8b8810107567dff2c0a93424ba1eb00b544cb78a5430f00f9bcf8f19bd663ae77849225577da05bfcdb57948a8af9dc32a7c8b9ffd
    HEAD_REF stable
    PATCHES
        uwp-cflags.patch
        parallel-install.patch
        allow-clang-cl.patch
)

vcpkg_list(SET EXTRA_ARGS)
set(nasm_archs x86 x64)
if(VCPKG_TARGET_ARCHITECTURE IN_LIST nasm_archs)
    vcpkg_find_acquire_program(NASM)
    list(APPEND EXTRA_ARGS CONFIGURE_ENVIRONMENT_VARIABLES AS)
    set(AS "${NASM}") # for CONFIGURE_ENVIRONMENT_VARIABLES
    set(ENV{AS} "${NASM}") # for non-WIN32
endif()

vcpkg_list(SET OPTIONS_RELEASE)
if("tool" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS_RELEASE --enable-cli)
else()
    vcpkg_list(APPEND OPTIONS_RELEASE --disable-cli)
endif()

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
        --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP
        --extra-cflags=-D_WIN32_WINNT=0x0A00
        --extra-ldflags=-APPCONTAINER
        --extra-ldflags=WindowsApp.lib
        --disable-asm
    )
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
