include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-3170000)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2017/sqlite-amalgamation-3170000.zip"
    FILENAME "sqlite-amalgamation-3170000.zip"
    SHA512 36dc05dbb21428237332e813181d4dd0c2ffaedb92a53934630c25421617afd9c1a65784665d222501f1b4b5c6445f425f8c512572a97e42603510dcc0796344
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSOURCE=${SOURCE_PATH}
)
vcpkg_build_cmake()
vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/sqlite3/sqlite3Config-debug.cmake SQLITE3_DEBUG_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" SQLITE3_DEBUG_CONFIG "${SQLITE3_DEBUG_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3Config-debug.cmake "${SQLITE3_DEBUG_CONFIG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
