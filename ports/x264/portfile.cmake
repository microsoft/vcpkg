set(X264_VERSION 164)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF 5db6aa6cab1b146e07b60cc1736a01f21da01154
    SHA512 d2cdd40d195fd6507abacc8b8810107567dff2c0a93424ba1eb00b544cb78a5430f00f9bcf8f19bd663ae77849225577da05bfcdb57948a8af9dc32a7c8b9ffd
    HEAD_REF stable
    PATCHES
        "uwp-cflags.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

if(VCPKG_TARGET_IS_WINDOWS)
    z_vcpkg_determine_autotools_host_cpu(BUILD_ARCH)
    z_vcpkg_determine_autotools_target_cpu(HOST_ARCH)
    list(APPEND OPTIONS --build=${BUILD_ARCH}-pc-mingw32)
    list(APPEND OPTIONS --host=${HOST_ARCH}-pc-mingw32)
    set(ENV{AS} "${NASM}")
endif()

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00)
    list(APPEND OPTIONS --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib)
    list(APPEND OPTIONS --disable-asm)
endif()

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND OPTIONS --enable-pic)
endif()

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    NO_ADDITIONAL_PATHS
    OPTIONS
        ${OPTIONS}
        --enable-strip
        --disable-lavf
        --disable-swscale
        --disable-avs
        --disable-ffms
        --disable-gpac
        --disable-lsmash
        --enable-debug

)

vcpkg_install_make()

if(NOT VCPKG_TARGET_IS_UWP)
    vcpkg_copy_tools(TOOL_NAMES x264 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x264.pc")
    if(EXISTS "${pcfile}")
      vcpkg_replace_string("${pcfile}" "-lx264" "-llibx264")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x264.pc")
      if(EXISTS "${pcfile}")
        vcpkg_replace_string("${pcfile}" "-lx264" "-llibx264")
      endif()
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/lib/libx264.lib)

    if (NOT VCPKG_BUILD_TYPE)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.lib)
    endif()
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # force U_STATIC_IMPLEMENTATION macro
    file(READ ${CURRENT_PACKAGES_DIR}/include/x264.h HEADER_CONTENTS)
    string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/x264.h "${HEADER_CONTENTS}")

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
