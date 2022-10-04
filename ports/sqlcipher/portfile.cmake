include(${CMAKE_CURRENT_LIST_DIR}/generate_amalgamation.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sqlcipher/sqlcipher
    REF v4.5.2
    SHA512 1de5b219392bb976631857e32b4523258fd660fedb558d478e536b7e10c711c72c7e7c9062e45bd8a5ceaecbc1fee717935d2357f6811c3ddf76702167f4601b
    HEAD_REF master
    PATCHES
        do-not-build-lemon.patch
)

set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")

# Creating amalgamation files

sqlcipher_generate_amalgamation(${SOURCE_PATH})

# The rest of the build process with the CMakeLists.txt is merely a copy of sqlite3

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION "${SOURCE_PATH}")

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

    INVERTED_FEATURES
        tool SQLITE3_SKIP_TOOLS
)

if(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DWITH_COMMONCRYPTO=ON)
else()
    list(APPEND FEATURE_OPTIONS -DWITH_OPENSSL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT SQLITE3_SKIP_TOOLS AND EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher-bin${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sqlcipher${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sqlcipher-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/sqlcipher-config.cmake"
    @ONLY
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
