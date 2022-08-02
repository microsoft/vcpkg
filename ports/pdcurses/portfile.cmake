vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF 6c1f95c4fa9f9f105879c2d99dd72a5bf335c046 # 3.9
    SHA512 2d682a3516baaa58a97854aca64d985768b7af76d998240b54afc57ddf2a44894835a1748888f8dd7c1cc8045ede77488284f8adf1b73878879b4b4d3391218d
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
