# Be sure to update both of these versions together.
set(SQLITE_VERSION 3390200)
set(PKGCONFIG_VERSION 3.39.2)
set(SQLITE_HASH a8fb7903cdc985d17b421035d6affe16795382085d7eb70428bdbbb4abc7ea6674aa251d4e532b531733c195e8867bfbd3c5556824c76cf321f8bc617bad6a32)

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

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
