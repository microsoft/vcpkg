include(vcpkg_common_functions)

set(SQLITE_VERSION 3250200)
set(SQLITE_HASH f87b4ab405f85df85b5d63e9e28c4db76202dc2d5461e0d0c626fa7521570d89a1122403c037704859ecb58ac1747ebf4b3c8a2f3a3c3d8492e8060df92e379f)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2018/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SQLITE_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(SQLITE3_SKIP_TOOLS ON)
if("tool" IN_LIST FEATURES)
    set(SQLITE3_SKIP_TOOLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSQLITE3_SKIP_TOOLS=${SQLITE3_SKIP_TOOLS}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3-config.cmake
    @ONLY
)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
