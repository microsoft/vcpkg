include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/PDCurses-3.4)
find_program(NMAKE nmake)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/pdcurses/files/latest/download?source=files"
    FILENAME "pdcurs34.zip"
    SHA512 cf2144359935ea553954e60e74318168d4c6fcee48648dfec74325742a61786b285c59ad0a014cc1f4039a332c3dbf2031c64865025a0cd25ef8faacc5827d05
)
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Build ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f vcwin32.mak WIDE=Y UTF8=Y PDCLIBS
    WORKING_DIRECTORY ${SOURCE_PATH}/win32
    LOGNAME build-${TARGET_TRIPLET}
)
message(STATUS "Build ${TARGET_TRIPLET} done")

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pdcurses RENAME copyright)
file(COPY ${SOURCE_PATH}/win32/pdcurses.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/win32/panel.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/curses.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/panel.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/term.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
