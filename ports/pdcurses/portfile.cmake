include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
find_program(NMAKE nmake)

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/pdcurses/pdcurses/3.4/pdcurs34.zip"
    FILENAME "pdcurs34.zip"
    SHA512 0b916bfe37517abb80df7313608cc4e1ed7659a41ce82763000dfdfa5b8311ffd439193c74fc84a591f343147212bf1caf89e7db71f1f7e4fa70f534834cb039
)
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Build ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f vcwin32.mak WIDE=Y UTF8=Y
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
