set(SQLITE_VERSION 3300100)
set(SQLITE_HASH 030b53fe684e0fb8e9747b1f160e5e875807eabb0763caff66fe949ee6aa92f26f409b9b25034d8d1f5cee554a99e56a2bb92129287b0fe0671409babe9d18ea )

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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    tool SQLITE3_SKIP_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(NOT SQLITE3_SKIP_TOOLS)
    file(RENAME ${CURRENT_PACKAGES_DIR}/tools/sqlite3-bin${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/sqlite3${VCPKG_HOST_EXECUTABLE_SUFFIX})
endif()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3-config.cmake
    @ONLY
)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()