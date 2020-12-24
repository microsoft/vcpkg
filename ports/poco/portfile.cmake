vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF 3fc3e5f5b8462f7666952b43381383a79b8b5d92 # poco-1.10.1-release
    SHA512 4c53a24a2ab9c57f4bf94e233da65cbb144c101b7d8d422d7e687d6c90ce0b53cb7bcfae63205ff30cade0fd07319e44a32035c1b15637ea2958986efc4ad5df
    HEAD_REF master
    PATCHES
        # Fix embedded copy of pcre in static linking mode
        static_pcre.patch
        # Add the support of arm64-windows
        arm64_pcre.patch
        fix_dependency.patch
)

file(REMOVE "${SOURCE_PATH}/Foundation/src/pcre.h")
file(REMOVE "${SOURCE_PATH}/cmake/V39/FindEXPAT.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/V313/FindSQLite3.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindPCRE.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMySQL.cmake")

# define Poco linkage type
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" POCO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        # force to use dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Define linking feature
        -DPOCO_STATIC=${POCO_STATIC}
        -DPOCO_MT=${POCO_MT}
        -DENABLE_TESTS=OFF
        -DENABLE_SAMPLES=OFF
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

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Move apps to the tools folder
vcpkg_copy_tools(TOOL_NAMES cpspc f2cpsp PocoDoc tec AUTO_CLEAN)

# Copy additional include files not part of any libraries
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL")
    file(COPY ${SOURCE_PATH}/Data/include DESTINATION ${CURRENT_PACKAGES_DIR})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/MySQL")
    file(COPY ${SOURCE_PATH}/Data/MySQL/include DESTINATION ${CURRENT_PACKAGES_DIR})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/ODBC")
    file(COPY ${SOURCE_PATH}/Data/ODBC/include DESTINATION ${CURRENT_PACKAGES_DIR})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/PostgreSQL")
    file(COPY ${SOURCE_PATH}/Data/PostgreSQL/include DESTINATION ${CURRENT_PACKAGES_DIR})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libpq)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/Poco/SQL/SQLite")
    file(COPY ${SOURCE_PATH}/Data/SQLite/include DESTINATION ${CURRENT_PACKAGES_DIR})
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Poco)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
