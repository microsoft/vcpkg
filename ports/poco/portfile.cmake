vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF de61f0049175a941cc83c2615c3bdc5e947b89f9 # poco-1.11.1-release
    SHA512 0290eeeca8a85286efe8f583224062ea97668c2730f8f7db4e075ce75e997b0a0c969159d4034c27fbb2e8d4b9c6504888d8ffa001193f7eb0e450bca2d5d7a2
    HEAD_REF master
    PATCHES
        # Fix embedded copy of pcre in static linking mode
        static_pcre.patch
        # Add the support of arm64-windows
        arm64_pcre.patch
        fix_dependency.patch
        fix-feature-sqlite3.patch
        fix-error-c3861.patch
        fix-InstallDataMysql.patch
)

file(REMOVE "${SOURCE_PATH}/Foundation/src/pcre.h")
file(REMOVE "${SOURCE_PATH}/cmake/V39/FindEXPAT.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/V313/FindSQLite3.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindPCRE.cmake")
file(REMOVE "${SOURCE_PATH}/XML/src/expat_config.h")
file(REMOVE "${SOURCE_PATH}/cmake/FindMySQL.cmake")

# define Poco linkage type
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" POCO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pdf         ENABLE_PDF
        netssl      ENABLE_NETSSL
        netssl      ENABLE_NETSSL_WIN
        netssl      ENABLE_CRYPTO
        sqlite3     ENABLE_DATA_SQLITE
        postgresql  ENABLE_DATA_POSTGRESQL
)

if ("mysql" IN_LIST FEATURES OR "mariadb" IN_LIST FEATURES)
    set(POCO_USE_MYSQL ON)
else()
    set(POCO_USE_MYSQL OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        # force to use dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Define linking feature
        -DPOCO_STATIC=${POCO_STATIC}
        -DPOCO_MT=${POCO_MT}
        -DENABLE_TESTS=OFF
        # Allow enabling and disabling components
        # POCO_ENABLE_SQL_ODBC, POCO_ENABLE_SQL_MYSQL and POCO_ENABLE_SQL_POSTGRESQL are
        # defined on the fly if the required librairies are present
        -DENABLE_ENCODINGS=ON
        -DENABLE_ENCODINGS_COMPILER=ON
        -DENABLE_XML=ON
        -DENABLE_JSON=ON
        -DENABLE_MONGODB=ON
        # -DPOCO_ENABLE_SQL_SQLITE=ON # SQLITE are not supported.
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
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Move apps to the tools folder
vcpkg_copy_tools(TOOL_NAMES cpspc f2cpsp PocoDoc tec arc AUTO_CLEAN)

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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
