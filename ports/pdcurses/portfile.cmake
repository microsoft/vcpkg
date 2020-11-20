vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF 6c1f95c4fa9f9f105879c2d99dd72a5bf335c046 # 3.9
    SHA512 2d682a3516baaa58a97854aca64d985768b7af76d998240b54afc57ddf2a44894835a1748888f8dd7c1cc8045ede77488284f8adf1b73878879b4b4d3391218d
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(PDC_NMAKE_CMD WIDE=Y UTF8=Y)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(PDC_NMAKE_CMD ${PDC_NMAKE_CMD} DLL=Y)
    endif()
    
    # Doesn't support install command
    vcpkg_build_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH wincon
        OPTIONS ${PDC_NMAKE_CMD}
        OPTIONS_DEBUG DEBUG=Y
    )
    
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(PDCURSES_BINARY_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/wincon)
        file (COPY ${PDCURSES_BINARY_DIR}/pdcurses.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file (COPY ${PDCURSES_BINARY_DIR}/pdcurses.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        endif()
    endif()
    
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(PDCURSES_BINARY_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/wincon)
        file (INSTALL ${PDCURSES_BINARY_DIR}/pdcurses.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file (INSTALL ${PDCURSES_BINARY_DIR}/pdcurses.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
    endif()
    
    vcpkg_copy_pdbs()
    
    file(INSTALL ${SOURCE_PATH}/curses.h ${SOURCE_PATH}/panel.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(READ ${CURRENT_PACKAGES_DIR}/include/curses.h _contents)
        string(REPLACE "#ifdef PDC_DLL_BUILD" "#if 1" _contents "${_contents}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/curses.h "${_contents}")
    endif()

else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH x11
        COPY_SOURCE
    )
    
    vcpkg_install_make()
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
