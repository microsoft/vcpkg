vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF ${VERSION}
    SHA512 4fd7c1221c5f34d94069a563dda7a796653148d903bc9023afe134b0f13bdc8b5d30000dfc80ab800e46e58b395ac2fb494d1316b80914998de5bacf0d7f3558
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
