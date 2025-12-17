vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF "poco-${VERSION}-release"
    SHA512 e192818a5f731ec6f6bddf062573d7bedfd15754157f145882c2c9d9bce497b92cf23f639f989d9e5605cb83029c4f303752cab655b525b5a5b5e5b704714725
    HEAD_REF devel
    PATCHES
        # Fix embedded copy of pcre in static linking mode
        0001-static-pcre.patch
        # Add the support of arm64-windows
        0002-arm64-pcre.patch
        0003-fix-dependency.patch
        0004-fix-feature-sqlite3.patch
        0005-fix-error-c3861.patch
        0007-find-pcre2.patch
        # MSYS2 repo was used as a source. Thanks MSYS2 team: https://github.com/msys2/MINGW-packages/blob/6e7fba42b7f50e1111b7c0ef50048832243b0ac4/mingw-w64-poco/001-fix-build-on-mingw.patch
        0008-fix-mingw-compilation.patch
        # Should be removed once https://github.com/pocoproject/poco/issues/4947 is resolved
        0009-fix-zip-to-xml-dependency.patch
)

file(REMOVE "${SOURCE_PATH}/Foundation/src/pcre2.h")
file(REMOVE "${SOURCE_PATH}/cmake/V39/FindEXPAT.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/V313/FindSQLite3.cmake")
# vcpkg's PCRE2 does not provide a FindPCRE2, and the bundled one seems to work fine
# file(REMOVE "${SOURCE_PATH}/cmake/FindPCRE2.cmake")
file(REMOVE "${SOURCE_PATH}/XML/src/expat_config.h")
file(REMOVE "${SOURCE_PATH}/cmake/FindMySQL.cmake")

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        # force to use dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Define linking feature
        -DPOCO_MT=${POCO_MT}
        -DENABLE_TESTS=OFF
        -DENABLE_SAMPLES=OFF
        # Allow enabling and disabling components done via features
        -DPOCO_DISABLE_INTERNAL_OPENSSL=ON
        -DENABLE_APACHECONNECTOR=OFF
        -DENABLE_DATA_MYSQL=${POCO_USE_MYSQL}
    MAYBE_UNUSED_VARIABLES # these are only used when if(MSVC)
        POCO_DISABLE_INTERNAL_OPENSSL
        POCO_MT
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
