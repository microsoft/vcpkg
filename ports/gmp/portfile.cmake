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
    set(PATCHES yasm.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF gmp-6.2.1
    PATCHES
        ${PATCHES}
        tools.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CCAS} "${CURRENT_HOST_INSTALLED_DIR}/tools/yasm-tool/yasm${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(asmflag win64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(asmflag win32)
    endif()
    set(ENV{ASMFLAGS} "-Xvc -f ${asmflag} -pgas -rraw")
    set(OPTIONS ac_cv_func_memset=yes
                "gmp_cv_asm_w32=.word"
                )
    
endif()
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --enable-cxx
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

