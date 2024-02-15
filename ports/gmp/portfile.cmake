if(EXISTS "${CURRENT_INSTALLED_DIR}/include/gmp.h" OR "${CURRENT_INSTALLED_DIR}/include/gmpxx.h")
    message(FATAL_ERROR "Can't build ${PORT} if mpir is installed. Please remove mpir, and try install ${PORT} again if you need it.")
endif()

vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

macro(z_vcpkg_acquire_msys_declare_package)
    set(msys_args "${ARGV}")
    string(REPLACE "autoconf2.72-2.72-1-any.pkg.tar.zst" "autoconf2.71-2.71-3-any.pkg.tar.zst" msys_args "${msys_args}")
    string(REPLACE "c8dc3e317dc4befc5f2848ac339a74f9dc8f021767aadb3d2c50b13869e0ef49fb48c62a0a1df5176a15a4f10196fcd2307efb83ff143ba1d20301882ba8dd1e" "dd312c428b2e19afd00899eb53ea4255794dea4c19d1d6dea2419cb6a54209ea2130d48abbc20af12196b9f628143436f736fbf889809c2c2291be0c69c0e306" msys_args "${msys_args}")
    string(REPLACE "autoconf2.72" "autoconf2.71" msys_args "${msys_args}")
    string(REPLACE "automake-wrapper-20221207-2-any.pkg.tar.zst" "automake-wrapper-20221207-1-any.pkg.tar.zst" msys_args "${msys_args}")
    string(REPLACE "4351c607edcf00df055b1310a790e41a63c575fbd80a6888d3693b88cad31d4628f9b96f849e319089893c826cf4473d9b31206d7ccb4cea15fd05b6b0ccb582" "22a65f75d1f19788cab93ecf70cb653fcedf67c18285ccbd2bb74ed1303dae8b09e9cfff40e8733920e75d8c4754d59481fa0c5b07d0c28803809448b011f45f" msys_args "${msys_args}")
    _z_vcpkg_acquire_msys_declare_package(${msys_args})
endmacro()

vcpkg_download_distfile(
    ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/gmp/gmp-${VERSION}.tar.xz"
        "https://ftp.gnu.org/gnu/gmp/gmp-${VERSION}.tar.xz"
        "https://gmplib.org/download/gmp/gmp-${VERSION}.tar.xz"
    FILENAME "gmp-${VERSION}.tar.xz"
    SHA512 c99be0950a1d05a0297d65641dd35b75b74466f7bf03c9e8a99895a3b2f9a0856cd17887738fa51cf7499781b65c049769271cbcb77d057d2e9f1ec52e07dd84
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
        gmp-arm64-asm-fix-5f32dbc41afc.patch # Avoid the x18 register since it is reserved on arm64 osx and windows. Source: https://gmplib.org/repo/gmp/raw-rev/5f32dbc41afc
)

vcpkg_list(SET OPTIONS)
if("fat" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS "--enable-fat")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND OPTIONS
        "ac_cv_func_memset=yes"
        "gmp_cv_asm_w32=.word"
        "gmp_cv_check_libm_for_build=no"
    )
endif()

set(disable_assembly OFF)
set(ccas "")
set(asmflags "-c")
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND asmflags " --target=i686-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND asmflags " --target=x86_64-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND asmflags " --target=arm64-pc-windows-msvc")
    else()
        set(disable_assembly ON)
    endif()
    if(NOT disable_assembly)
        vcpkg_find_acquire_program(CLANG)
        set(ccas "${CLANG}")
    endif()
elseif(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # not exporting asm functions
    set(disable_assembly ON)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    vcpkg_list(APPEND OPTIONS "ABI=32")
    string(APPEND asmflags " -m32")
else()
    set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
endif()

if(disable_assembly)
    vcpkg_list(APPEND OPTIONS "--enable-assembly=no")
elseif(ccas)
    cmake_path(GET ccas PARENT_PATH ccas_dir)
    vcpkg_add_to_path("${ccas_dir}")
    cmake_path(GET ccas FILENAME ccas_command)
endif()
vcpkg_list(APPEND OPTIONS "CCAS=${ccas_command}" "ASMFLAGS=${asmflags}")

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
        --with-readline=no
        "gmp_cv_prog_exeext_for_build=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-bases${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-fac${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-fib${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-jacobitab${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen-psqr${VCPKG_HOST_EXECUTABLE_SUFFIX}"
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
