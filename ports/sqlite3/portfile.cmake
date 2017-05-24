include(vcpkg_common_functions)

set(SQLITE_VERSION 3190100)
set(SQLITE_HASH 14064707d9ca029131ec92863026748e184ad4d6ca9d25e941fc254d9ad24f1451fc5fae6516603a420925aab1736e3fb92085f03d8dc47ec913839e158652c4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-${SQLITE_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2017/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH})
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOURCE=${SOURCE_PATH}
        -DVCPKG_CMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}
)
vcpkg_build_cmake()
vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/sqlite3/sqlite3Config-debug.cmake SQLITE3_DEBUG_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" SQLITE3_DEBUG_CONFIG "${SQLITE3_DEBUG_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3Config-debug.cmake "${SQLITE3_DEBUG_CONFIG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
