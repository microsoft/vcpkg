include(vcpkg_common_functions)

# Poco 2.0.0 (pre)
# commit 46e00c8
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pocoproject/poco
    REF 46e00c8d6f6d03864397c3e517a165e82f9efd5e
    SHA512 2c2f5048b7bfbbfe47ac303ed79213197c97f3d90362dd2d7629c8b353a6c8bd303b1bcf477e3493cc6c984645822ca043dd0a77e9186e001e6808dc2d17a5b4
    HEAD_REF develop
    PATCHES
        # Find pcre in debug
        find_pcre.patch
        # Add include path to public interface for static build
        include_pcre.patch
        # Fix embedded copy of pcre in static linking mode
        static_pcre.patch
        # Fix source path of PDF
        unbundled_pdf.patch
        # Add the support of arm64-windows
        arm64_pcre.patch
)

# define Poco linkage type
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" POCO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" POCO_MT)

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
    OPTIONS
        # Set to OFF|ON (default is OFF) to control linking dependencies as external
        -DPOCO_UNBUNDLED=ON
        # Define linking feature
        -DPOCO_STATIC=${POCO_STATIC}
        -DPOCO_MT=${POCO_MT}
        # Set to OFF|ON (default is OFF) to control build of POCO tests
        -DPOCO_ENABLE_TESTS=OFF
        # Set to OFF|ON (default is OFF) to control build of POCO samples
        -DPOCO_ENABLE_SAMPLES=OFF
        # Allow enabling and disabling components
        # POCO_ENABLE_SQL_ODBC, POCO_ENABLE_SQL_MYSQL and POCO_ENABLE_SQL_POSTGRESQL are
        # defined on the fly if the required librairies are present
        -DPOCO_ENABLE_ENCODINGS=ON
        -DPOCO_ENABLE_ENCODINGS_COMPILER=ON
        -DPOCO_ENABLE_XML=ON
        -DPOCO_ENABLE_JSON=ON
        -DPOCO_ENABLE_MONGODB=ON
        -DPOCO_ENABLE_SQL_SQLITE=ON
        -DPOCO_ENABLE_REDIS=ON
        -DPOCO_ENABLE_PDF=ON
        -DPOCO_ENABLE_UTIL=ON
        -DPOCO_ENABLE_NET=ON
        -DPOCO_ENABLE_SEVENZIP=ON
        -DPOCO_ENABLE_ZIP=ON
        -DPOCO_ENABLE_CPPPARSER=ON
        -DPOCO_ENABLE_POCODOC=ON
        -DPOCO_ENABLE_PAGECOMPILER=ON
        -DPOCO_ENABLE_PAGECOMPILER_FILE2PAGE=ON
        -DPOCO_ENABLE_WSTRING=ON
        -DPOCO_ENABLE_FPENVIRONMENT=ON
        -DPOCO_ENABLE_CPPUNIT=ON
        #
        -DMYSQL_INCLUDE_DIR=${MYSQL_INCLUDE_DIR}
    OPTIONS_RELEASE
        -DMYSQL_LIBRARY=${MYSQL_LIBRARY}
    OPTIONS_DEBUG
        -DMYSQL_LIBRARY=${MYSQL_LIBRARY_DEBUG}
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
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/poco)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/poco/LICENSE ${CURRENT_PACKAGES_DIR}/share/poco/copyright)

vcpkg_copy_pdbs()
