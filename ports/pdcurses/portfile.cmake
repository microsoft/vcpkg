
if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "PDCurses only supports dynamic CRT linkage")
endif()

include(vcpkg_common_functions)
find_program(NMAKE nmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wmcbrine/PDCurses
    REF 2467ab2b6c07163d0171b80ad6c252c29da28173
    SHA512 6c120932e8b02d60e0bc0fbbec8789fa9afa9a57ff0c42543c6227e617716e991655a7d4383df3a08456bbe0d1e1bafe84061074dca801df5ecf9a352b883b35
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
