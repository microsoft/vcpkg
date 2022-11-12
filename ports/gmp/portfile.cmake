if(EXISTS "${CURRENT_INSTALLED_DIR}/include/gmp.h" OR "${CURRENT_INSTALLED_DIR}/include/gmpxx.h")
    message(FATAL_ERROR "Can't build ${PORT} if mpir is installed. Please remove mpir, and try install ${PORT} again if you need it.")
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz
    FILENAME gmp-6.2.1.tar.xz
    SHA512 c99be0950a1d05a0297d65641dd35b75b74466f7bf03c9e8a99895a3b2f9a0856cd17887738fa51cf7499781b65c049769271cbcb77d057d2e9f1ec52e07dd84
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES yasm.patch
                msvc_symbol.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF gmp-6.2.1
    PATCHES
        cross-tools.patch
        subdirs.patch
        ${PATCHES}
)

vcpkg_list(SET OPTIONS)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND OPTIONS "ac_cv_func_memset=yes")
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(arm|arm64)$")
        vcpkg_list(APPEND OPTIONS --enable-assembly=no)
    else()
        set(ENV{CCAS} "${CURRENT_HOST_INSTALLED_DIR}/tools/yasm/yasm${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(asmflag win64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(asmflag win32)
        endif()
        set(ENV{ASMFLAGS} "-Xvc -f ${asmflag} -pgas -rraw")
        vcpkg_list(APPEND OPTIONS "gmp_cv_asm_w32=.word")
    endif()
elseif(VCPKG_CROSSCOMPILING)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    vcpkg_list(APPEND OPTIONS "CCAS=${VCPKG_DETECTED_CMAKE_C_COMPILER} -c")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --enable-cxx
        --with-pic
        "gmp_cv_prog_exeext_for_build=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    set(tool_names bases fac fib jacobitab psqr trialdivtab)
    list(TRANSFORM tool_names PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-")
    list(TRANSFORM tool_names APPEND "${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(INSTALL ${tool_names} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}" USE_SOURCE_PERMISSIONS)
    vcpkg_copy_tool_dependencies("${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/README"
        "${SOURCE_PATH}/COPYING.LESSERv3"
        "${SOURCE_PATH}/COPYINGv3"
        "${SOURCE_PATH}/COPYINGv2"
)
