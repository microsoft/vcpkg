vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF f2d31a2633eb042f7bf1f79cba81522915a04579 # committed on 2022-10-20
    SHA512 2fbd82f5ab4dafea5a6ad87645a1e995963c814c062501760315d362a6cd0f6f2c9143c5e28f15db4d11ee77164f0ec5e920386fa0b92fdba195cc6452eee1b9
    HEAD_REF master
    PATCHES
        nmake-install.patch
)
 
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    cmake_path(NATIVE_PATH SOURCE_PATH  PDCURSES_SRCDIR)
    set(DLL_OPTION "")
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(DLL_OPTION DLL=Y)
    endif()
    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}/wincon"
        PROJECT_NAME Makefile.vc
        ENABLE_INSTALL
        OPTIONS
            /A
            "PDCURSES_SRCDIR=${PDCURSES_SRCDIR}"
            WIDE=Y
            UTF8=Y
            ${DLL_OPTION}
        OPTIONS_RELEASE
            "CFLAGS=-D_CRT_SECURE_NO_WARNINGS"
            "LDFLAGS="
        OPTIONS_DEBUG
            "CFLAGS=-D_CRT_SECURE_NO_WARNINGS -DPDCDEBUG"
            "LDFLAGS=-debug"
            DEBUG=Y
            SKIP_HEADERS=Y
    )
    vcpkg_copy_pdbs()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/curses.h" "#ifdef PDC_DLL_BUILD" "#if 1")
    endif()
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-pdcurses-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")
