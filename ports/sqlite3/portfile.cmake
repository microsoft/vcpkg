include(vcpkg_common_functions)

set(SQLITE_VERSION 3210000)
set(SQLITE_HASH 0a272b00825d07528c3842ccd483d81e5e719ab56737eec0972f7f8191dfbe92e35777ab8d1b37c95fde9320bbfa3c365a4b30253af876340f55517ea96bf665)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-${SQLITE_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2017/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH})
vcpkg_extract_source_archive(${ARCHIVE})

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

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/sqlite3/sqlite3Config-debug.cmake SQLITE3_DEBUG_CONFIG)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" SQLITE3_DEBUG_CONFIG "${SQLITE3_DEBUG_CONFIG}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3Config-debug.cmake "${SQLITE3_DEBUG_CONFIG}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
