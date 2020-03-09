include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF 8a127d6f16795d914cadc342d3f4f3b9b7999e3b #1.9.2
    SHA512 282097ee2118ac55320ebdde05bb53ed27d68af49c201b0b26027706ef935ae08f8090abb8aab1cafe84c72520ea73b01263b439d32bd2d0bd55319b0634b168
    HEAD_REF master
    PATCHES
        # Find pcre in debug
        find_pcre.patch
        # Add include path to public interface for static build
        include_pcre.patch
        # Fix embedded copy of pcre in static linking mode
        static_pcre.patch
        # Use vcpkg installed libharu for feature pdf
        use-vcpkg-libharu.patch
        # Add the support of arm64-windows
        arm64_pcre.patch
        fix_foundation_link.patch
)

# define Poco linkage type
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" POCO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    pdf ENABLE_PDF
)

# MySQL / MariaDDB feature
if("mysql" IN_LIST FEATURES OR "mariadb" IN_LIST FEATURES)
    if("mysql" IN_LIST FEATURES)
        # enabling MySQL support
        set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql")
        set(MYSQL_LIBRARY "${CURRENT_INSTALLED_DIR}/lib/libmysql.lib")
        set(MYSQL_LIBRARY_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/libmysql.lib")
    endif()
    if("mariadb" IN_LIST FEATURES)
        # enabling MariaDB support
        set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql")
        set(MYSQL_LIBRARY "${CURRENT_INSTALLED_DIR}/lib/libmariadb.lib")
        set(MYSQL_LIBRARY_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/libmariadb.lib")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    #PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        # Set to OFF|ON (default is OFF) to control linking dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Define linking feature
        -DPOCO_STATIC=${POCO_STATIC}
        -DPOCO_MT=${POCO_MT}
        # Set to OFF|ON (default is OFF) to control build of POCO tests
        -DENABLE_TESTS=OFF
        # Set to OFF|ON (default is OFF) to control build of POCO samples
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
        #
        -DMYSQL_INCLUDE_DIR=${MYSQL_INCLUDE_DIR}
    OPTIONS_RELEASE
        -DMYSQL_LIB=${MYSQL_LIBRARY}
    OPTIONS_DEBUG
        -DMYSQL_LIB=${MYSQL_LIBRARY_DEBUG}
)

vcpkg_install_cmake()


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


# Move apps to the tools folder
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cpspc.exe")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc.exe ${CURRENT_PACKAGES_DIR}/tools/cpspc.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.exe ${CURRENT_PACKAGES_DIR}/tools/f2cpsp.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/PocoDoc.exe ${CURRENT_PACKAGES_DIR}/tools/PocoDoc.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/tec.exe ${CURRENT_PACKAGES_DIR}/tools/tec.exe)
else()
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc ${CURRENT_PACKAGES_DIR}/tools/cpspc)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp ${CURRENT_PACKAGES_DIR}/tools/f2cpsp)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/PocoDoc ${CURRENT_PACKAGES_DIR}/tools/PocoDoc)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/tec ${CURRENT_PACKAGES_DIR}/tools/tec)
endif()


#
if (VCPKG_LIBRARY_LINKAGE STREQUAL static OR VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.pdb
        ${CURRENT_PACKAGES_DIR}/bin/PocoDoc.pdb
        ${CURRENT_PACKAGES_DIR}/bin/tec.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/PocoDoc.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/PocoDoc.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/tec.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/tec.pdb)
endif()

#
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/Poco")
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Poco)
endif()

# remove unused files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()
