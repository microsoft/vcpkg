vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF c04dfdbc37882f298d3178b3875cd67c38ea7d78 # poco-1.12.5-release
    SHA512 a9dfe8981ba15049a0824ce5dbe79df5032d96bf204e7780719f987ef86b21cde5bb8a19340c5d5c34a33d60955341a386057f14a6f16bad9657e8880b12294d
    HEAD_REF master
    PATCHES
        # Fix embedded copy of pcre in static linking mode
        0001-static-pcre.patch
        # Add the support of arm64-windows
        0002-arm64-pcre.patch
        0003-fix-dependency.patch
        0004-fix-feature-sqlite3.patch
        0005-fix-error-c3861.patch
        0007-find-pcre2.patch
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
        crypto      ENABLE_CRYPTO
        netssl      ENABLE_NETSSL
        pdf         ENABLE_PDF
        sqlite3     ENABLE_DATA_SQLITE
        postgresql  ENABLE_DATA_POSTGRESQL
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
        # Allow enabling and disabling components
        -DENABLE_ENCODINGS=ON
        -DENABLE_ENCODINGS_COMPILER=ON
        -DENABLE_XML=ON
        -DENABLE_JSON=ON
        -DENABLE_MONGODB=ON
        -DENABLE_REDIS=ON
        -DENABLE_UTIL=ON
        -DENABLE_NET=ON
        -DENABLE_SEVENZIP=ON
        -DENABLE_ZIP=ON
        -DENABLE_CPPPARSER=ON
        -DENABLE_POCODOC=ON
        -DENABLE_PAGECOMPILER=ON
        -DENABLE_PAGECOMPILER_FILE2PAGE=ON
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
vcpkg_copy_tools(TOOL_NAMES cpspc f2cpsp PocoDoc tec arc AUTO_CLEAN)

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
