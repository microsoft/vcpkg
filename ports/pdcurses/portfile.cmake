
if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "PDCurses only supports dynamic CRT linkage")
endif()

include(vcpkg_common_functions)
find_program(NMAKE nmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF 3.6
    SHA512 1ed34e7eb791c9e00aae60878339e79f6b3af086c45d88d2b59d9b2b4020481ff5a5c21e078e59ae24f2de3b4d412f0240f21a50eb743f7e172c832a7e17ed5e
    HEAD_REF master
)

file(REMOVE_RECURSE
    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
)

file(GLOB SOURCES ${SOURCE_PATH}/*)

file(COPY ${SOURCES} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

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
    COPY ${PDC_PDCLIB}.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file (
        COPY ${PDC_PDCLIB}.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

file(
    COPY ${SOURCE_PATH}/curses.h ${SOURCE_PATH}/panel.h ${SOURCE_PATH}/term.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pdcurses RENAME copyright)

vcpkg_copy_pdbs()
