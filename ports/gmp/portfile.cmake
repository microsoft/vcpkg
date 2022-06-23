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
        ${PATCHES}
        tools.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CCAS} "${CURRENT_HOST_INSTALLED_DIR}/tools/yasm/yasm${VCPKG_HOST_EXECUTABLE_SUFFIX}")
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

if(VCPKG_CROSSCOMPILING)
    # Silly trick to make configure accept CC_FOR_BUILD but in reallity CC_FOR_BUILD is deactivated. 
    set(ENV{CC_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
    set(ENV{CPP_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --enable-cxx
        --with-pic
)

set(tool_names bases fac fib jacobitab psqr trialdivtab)
list(TRANSFORM tool_names PREPEND "gen-")
list(TRANSFORM tool_names APPEND "${VCPKG_HOST_EXECUTABLE_SUFFIX}")

if(VCPKG_CROSSCOMPILING)
    list(TRANSFORM tool_names PREPEND "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/")
    file(COPY ${tool_names} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/" )
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY ${tool_names} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/" )
    endif()
endif()

vcpkg_install_make()

if(NOT VCPKG_CROSSCOMPILING)
    list(TRANSFORM tool_names PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    file(COPY ${tool_names} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}" )
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

