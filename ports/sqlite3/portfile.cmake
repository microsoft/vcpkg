include(vcpkg_common_functions)

set(SQLITE_VERSION 3240000)
set(SQLITE_HASH c7050bdd33c50b24e8c9fd2409b7bccbdcd8d6f064b435ee34b6c4a4de6283bce2500d4a3aa3821be2069804dff45a575ff331c97b39e02b227ef32e542ed6cb)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-${SQLITE_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2018/sqlite-amalgamation-${SQLITE_VERSION}.zip"
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
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3-config.cmake
    @ONLY
)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()
