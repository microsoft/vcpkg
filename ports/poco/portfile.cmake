vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF "poco-${VERSION}-release"
    SHA512 b1f9eee8a1e72e847fbcf550974d3ecee768fa824c942f301fa8e2a667629f1c2c787e1255da8faeb4d7e2b99022b3628ea00f8af5fadb5d98e5af06a17d6571
    HEAD_REF devel
    PATCHES
        # Add the support of arm64-windows
        0002-arm64-pcre.patch
        0003-fix-dependency.patch
        # MSYS2 repo was used as a source. Thanks MSYS2 team: https://github.com/msys2/MINGW-packages/blob/6e7fba42b7f50e1111b7c0ef50048832243b0ac4/mingw-w64-poco/001-fix-build-on-mingw.patch
        0008-fix-mingw-compilation.patch
)

file(REMOVE
    "${SOURCE_PATH}/cmake/FindMySQL.cmake"
    "${SOURCE_PATH}/cmake/FindPCRE2.cmake"
    "${SOURCE_PATH}/cmake/FindUtf8Proc.cmake"
)

# define Poco linkage type
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        crypto                  ENABLE_CRYPTO
        netssl                  ENABLE_NETSSL
        pdf                     ENABLE_PDF
        postgresql              ENABLE_DATA_POSTGRESQL
        encodings               ENABLE_ENCODINGS
        encodings-compiler      ENABLE_ENCODINGS_COMPILER
        xml                     ENABLE_XML
        json                    ENABLE_JSON
        mongodb                 ENABLE_MONGODB
        redis                   ENABLE_REDIS
        prometheus              ENABLE_PROMETHEUS
        util                    ENABLE_UTIL
        net                     ENABLE_NET
        zip                     ENABLE_ZIP
        pocodoc                 ENABLE_POCODOC
        pagecompiler            ENABLE_PAGECOMPILER
        pagecompiler-file2page  ENABLE_PAGECOMPILER_FILE2PAGE
        jwt                     ENABLE_JWT
        data                    ENABLE_DATA
        sqlite                  ENABLE_DATA_SQLITE
        odbc                    ENABLE_DATA_ODBC
        activerecord            ENABLE_ACTIVERECORD
        activerecord-compiler   ENABLE_ACTIVERECORD_COMPILER
        sevenzip                ENABLE_SEVENZIP
        cpp-parser              ENABLE_CPPPARSER
)

# POCO_ENABLE_NETSSL_WIN:
# Use the unreleased NetSSL_Win module instead of (OpenSSL) NetSSL.
# This is a variable which can be set in the triplet file.
if(POCO_ENABLE_NETSSL_WIN)
    string(REPLACE "ENABLE_NETSSL" "ENABLE_NETSSL_WIN" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
    list(APPEND FEATURE_OPTIONS "-DENABLE_NETSSL:BOOL=OFF")
endif()

if ("mysql" IN_LIST FEATURES OR "mariadb" IN_LIST FEATURES)
    set(POCO_USE_MYSQL ON)
else()
    set(POCO_USE_MYSQL OFF)
endif()
if(NOT "mysql" IN_LIST FEATURES)
    # Use libmariadb even if libmysql happens to be installed
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_unofficial-libmysql=ON")
endif()
if(ENABLE_DATA_ODBC)
    # Do not pick up an undeclared SQL Server driver header from the host.
    list(APPEND FEATURE_OPTIONS "-D_msodbc_h:FILEPATH=")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        # force to use dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Only build the components enabled by features, and don't look for
        # optional dependencies (OpenSSL, MySQL, PostgreSQL, ODBC, Apache)
        -DPOCO_MINIMAL_BUILD=ON
        # Define linking feature
        -DPOCO_MT=${POCO_MT}
        -DENABLE_TESTS=OFF
        -DENABLE_SAMPLES=OFF
        -DENABLE_APACHECONNECTOR=OFF
        -DENABLE_DATA_MYSQL=${POCO_USE_MYSQL}
        -DENABLE_DATA_SQL_SERVER_BIG_STRINGS=OFF
        # FastLogger would compile a bundled copy of quill into PocoFoundation
        -DENABLE_FASTLOGGER=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_unofficial-libmysql
        ENABLE_DATA_SQL_SERVER_BIG_STRINGS
        POCO_MT # only used when if(MSVC)
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Move apps to the tools folder
set(tools)
if (ENABLE_PAGECOMPILER)
    list(APPEND tools "cpspc")
endif()
if (ENABLE_PAGECOMPILER_FILE2PAGE)
    list(APPEND tools "f2cpsp")
endif()
if (ENABLE_POCODOC)
    list(APPEND tools "PocoDoc")
endif()
if (ENABLE_ENCODINGS_COMPILER)
    list(APPEND tools "tec")
endif()
if (ENABLE_ACTIVERECORD_COMPILER)
    list(APPEND tools "poco-arc")
endif()
if (tools)
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Copy additional include files not part of any libraries
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL")
    file(COPY "${SOURCE_PATH}/Data/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/MySQL")
    file(COPY "${SOURCE_PATH}/Data/MySQL/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/ODBC")
    file(COPY "${SOURCE_PATH}/Data/ODBC/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/PostgreSQL")
    file(COPY "${SOURCE_PATH}/Data/PostgreSQL/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libpq")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/SQLite")
    file(COPY "${SOURCE_PATH}/Data/SQLite/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Poco)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/dependencies/tessil/include/Poco/ordered_hash.h"
        "${SOURCE_PATH}/dependencies/pcre2/src/pcre2_ucd.c"
        "${SOURCE_PATH}/dependencies/wepoll/src/wepoll.h"
)
