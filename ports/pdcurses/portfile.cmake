vcpkg_check_linkage(ONLY_DYNAMIC_CRT)

find_program(NMAKE nmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF 6c1f95c4fa9f9f105879c2d99dd72a5bf335c046 # 3.9
    SHA512 2d682a3516baaa58a97854aca64d985768b7af76d998240b54afc57ddf2a44894835a1748888f8dd7c1cc8045ede77488284f8adf1b73878879b4b4d3391218d
    HEAD_REF master
)

set(PDC_NMAKE_CMD ${NMAKE} /A -f ${SOURCE_PATH}/wincon/Makefile.vc WIDE=Y UTF8=Y)

set(PDC_NMAKE_CWD ${SOURCE_PATH}/wincon)
set(PDC_PDCLIB ${SOURCE_PATH}/wincon/pdcurses)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(PDC_NMAKE_CMD ${PDC_NMAKE_CMD} DLL=Y)
endif()

message(STATUS "Build ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${PDC_NMAKE_CMD}
    WORKING_DIRECTORY ${PDC_NMAKE_CWD}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Build ${TARGET_TRIPLET}-rel done")

file (
    COPY ${PDC_PDCLIB}.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file (
        COPY ${PDC_PDCLIB}.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
endif()

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PDC_NMAKE_CMD} DEBUG=Y
    WORKING_DIRECTORY ${PDC_NMAKE_CWD}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")

file (
    INSTALL ${PDC_PDCLIB}.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file (
        INSTALL ${PDC_PDCLIB}.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

file(
    INSTALL ${SOURCE_PATH}/curses.h ${SOURCE_PATH}/panel.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(READ ${CURRENT_PACKAGES_DIR}/include/curses.h _contents)
    string(REPLACE "#ifdef PDC_DLL_BUILD" "#if 1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/curses.h "${_contents}")
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pdcurses RENAME copyright)

vcpkg_copy_pdbs()