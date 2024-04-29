if(EXISTS "${CURRENT_INSTALLED_DIR}/include/gmp.h" OR "${CURRENT_INSTALLED_DIR}/include/gmpxx.h")
    message(FATAL_ERROR "Can't build ${PORT} if mpir is installed. Please remove mpir, and try install ${PORT} again if you need it.")
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/gmp/gmp-${VERSION}.tar.xz"
        "https://ftp.gnu.org/gnu/gmp/gmp-${VERSION}.tar.xz"
        "https://gmplib.org/download/gmp/gmp-${VERSION}.tar.xz"
    FILENAME "gmp-${VERSION}.tar.xz"
    SHA512 e85a0dab5195889948a3462189f0e0598d331d3457612e2d3350799dba2e244316d256f8161df5219538eb003e4b5343f989aaa00f96321559063ed8c8f29fd2
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        asmflags.patch
        cross-tools.patch
        subdirs.patch
        msvc_symbol.patch
        arm64-coff.patch
)

vcpkg_list(SET OPTIONS)
if("fat" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS "--enable-fat")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND OPTIONS
        "gmp_cv_asm_w32=.word"
        "gmp_cv_check_libm_for_build=no"
    )
endif()

set(disable_assembly OFF)
set(languages "C;CXX")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    else()
        set(disable_assembly ON)
    endif()
elseif(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # not exporting asm functions
    set(disable_assembly ON)
endif()

if(disable_assembly)
    vcpkg_list(APPEND OPTIONS "--enable-assembly=no")
else()
    list(APPEND languages "ASM")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

vcpkg_make_configure(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    LANGUAGES ${languages}
    OPTIONS
        ${OPTIONS}
        --enable-cxx
        --with-pic
        --with-readline=no
        "gmp_cv_prog_exeext_for_build=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-bases${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-fac${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-fib${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-jacobitab${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-psqr${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-sieve${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-trialdivtab${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
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
