include(vcpkg_common_functions)

set(SQLITE_VERSION 3290000)
set(SQLITE_HASH 3306ac3e37ec46f1b2ac74155756c82afadff7bf5b8b4c9b5516f5e8c1c785b5f50ec9b840482292f2f6c5d72cf6d9a78a0dfb727f0a9cf134b6c5522606e9b3 )

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2019/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SQLITE_VERSION}
    PATCHES fix-arm-uwp.patch
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
