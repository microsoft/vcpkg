# Be sure to update both of these versions together.
set(SQLITE_VERSION 3390100)
set(PKGCONFIG_VERSION 3.39.1)
set(SQLITE_HASH e36f30839e0884d021f05f1220a6cf8956156bb00f1f661dcdbe1771ddeb7836e8348034c5e993194a5f28167affda2add6922b6aff4921854bbe566b2254a84)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2022/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SQLITE_VERSION}
    PATCHES fix-arm-uwp.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/sqlite3.pc.in" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fts3                ENABLE_FTS3
        fts4                ENABLE_FTS4
        fts5                ENABLE_FTS5
        memsys3             ENABLE_MEMSYS3
        memsys5             ENABLE_MEMSYS5
        math                ENABLE_MATH_FUNCTION
        limit               ENABLE_LIMIT
        rtree               ENABLE_RTREE
        session             ENABLE_SESSION
        omit-load-extension ENABLE_OMIT_LOAD_EXT
        geopoly             WITH_GEOPOLY
        json1               WITH_JSON1
        zlib                WITH_ZLIB
        INVERTED_FEATURES
        tool                SQLITE3_SKIP_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPKGCONFIG_VERSION=${PKGCONFIG_VERSION}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT} CONFIG_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT SQLITE3_SKIP_TOOLS AND EXISTS "${CURRENT_PACKAGES_DIR}/tools/sqlite3-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/sqlite3-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/sqlite3${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-sqlite3-config.cmake"
    @ONLY
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sqlite3.h" "# define SQLITE_API\n" "# define SQLITE_API __declspec(dllimport)\n")
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
