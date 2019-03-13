# vcpkg portfile.cmake for GDAL
#
# NOTE: update the version and checksum for new GDAL release
set(GDAL_VERSION_STR "2.4.0")
set(GDAL_VERSION_PKG "240")
set(GDAL_VERSION_LIB "204")
set(GDAL_PACKAGE_SUM "a8543425d7bdbb5ab94638a490fe5b62e37983fbb89e1eea98b0e31d5fa76b7568e7b633c90ac429c87a6c9e8d9e1358b48428f3885aac8d574d1f01e9631f7f")

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "GDAL's nmake buildsystem does not support building static libraries")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "GDAL's nmake buildsystem does not support static crt linkage")
endif()

include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/gdal/${GDAL_VERSION_STR}/gdal${GDAL_VERSION_PKG}.zip"
    FILENAME "gdal${GDAL_VERSION_PKG}.zip"
    SHA512 ${GDAL_PACKAGE_SUM}
)

# Extract source into architecture specific directory, because GDALs' nmake based build currently does not
# support out of source builds.
set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/gdal-${GDAL_VERSION_STR})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/gdal-${GDAL_VERSION_STR})

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND BUILD_TYPES "release")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND BUILD_TYPES "debug")
endif()

foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/gdal-${GDAL_VERSION_STR}
        PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-Fix-debug-crt-flags.patch
    )
endforeach()

find_program(NMAKE nmake REQUIRED)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal" NATIVE_DATA_DIR)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal/html" NATIVE_HTML_DIR)

# Setup proj4 libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PROJ_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/proj.lib" PROJ_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/projd.lib" PROJ_LIBRARY_DBG)

# Setup libpng libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PNG_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpng16.lib" PNG_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib" PNG_LIBRARY_DBG)

# Setup geos libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" GEOS_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib" GEOS_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib" GEOS_LIBRARY_DBG)

# Setup expat libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" EXPAT_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/expat.lib" EXPAT_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/expat.lib" EXPAT_LIBRARY_DBG)

# Setup curl libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" CURL_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib" CURL_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl.lib" CURL_LIBRARY_DBG)

# Setup sqlite3 libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" SQLITE_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib" SQLITE_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib" SQLITE_LIBRARY_DBG)

# Setup PostgreSQL libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PGSQL_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpq.lib" PGSQL_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpqd.lib" PGSQL_LIBRARY_DBG)

# Setup OpenJPEG libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" OPENJPEG_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/openjp2.lib" OPENJPEG_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/openjp2.lib" OPENJPEG_LIBRARY_DBG)

# Setup WebP libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" WEBP_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/webp.lib" WEBP_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/webpd.lib" WEBP_LIBRARY_DBG)

# Setup libxml2 libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" XML2_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib" XML2_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib" XML2_LIBRARY_DBG)

# Setup liblzma libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" LZMA_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/lzma.lib" LZMA_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/lzma.lib" LZMA_LIBRARY_DBG)

if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
    # Setup MySQL libraries + include path
    if("mysql-libmysql" IN_LIST FEATURES)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include/mysql" MYSQL_INCLUDE_DIR)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libmysql.lib" MYSQL_LIBRARY_REL)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libmysql.lib" MYSQL_LIBRARY_DBG)
    endif()

    if("mysql-libmariadb" IN_LIST FEATURES)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include/mysql" MYSQL_INCLUDE_DIR)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libmariadb.lib" MYSQL_LIBRARY_REL)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libmariadb.lib" MYSQL_LIBRARY_DBG)
    endif()

    list(APPEND NMAKE_OPTIONS MYSQL_INC_DIR=${MYSQL_INCLUDE_DIR})
    list(APPEND NMAKE_OPTIONS_REL MYSQL_LIB=${MYSQL_LIBRARY_REL})
    list(APPEND NMAKE_OPTIONS_DBG MYSQL_LIB=${MYSQL_LIBRARY_DBG})
endif()

list(APPEND NMAKE_OPTIONS
    GDAL_HOME=${NATIVE_PACKAGES_DIR}
    DATADIR=${NATIVE_DATA_DIR}
    HTMLDIR=${NATIVE_HTML_DIR}
    GEOS_DIR=${GEOS_INCLUDE_DIR}
    "GEOS_CFLAGS=-I${GEOS_INCLUDE_DIR} -DHAVE_GEOS"
    PROJ_INCLUDE=-I${PROJ_INCLUDE_DIR}
    EXPAT_DIR=${EXPAT_INCLUDE_DIR}
    EXPAT_INCLUDE=-I${EXPAT_INCLUDE_DIR}
    CURL_INC=-I${CURL_INCLUDE_DIR}
    SQLITE_INC=-I${SQLITE_INCLUDE_DIR}
    PG_INC_DIR=${PGSQL_INCLUDE_DIR}
    OPENJPEG_ENABLED=YES
    OPENJPEG_CFLAGS=-I${OPENJPEG_INCLUDE_DIR}
    OPENJPEG_VERSION=20100
    WEBP_ENABLED=YES
    WEBP_CFLAGS=-I${WEBP_INCLUDE_DIR}
    LIBXML2_INC=-I${XML2_INCLUDE_DIR}
    PNG_EXTERNAL_LIB=1
    PNGDIR=${PNG_INCLUDE_DIR}
    MSVC_VER=1900
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND NMAKE_OPTIONS WIN64=YES)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND NMAKE_OPTIONS PROJ_FLAGS=-DPROJ_STATIC)
else()
    # Enables PDBs for release and debug builds
    list(APPEND NMAKE_OPTIONS WITH_PDB=1)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(LINKAGE_FLAGS "/MT")
else()
    set(LINKAGE_FLAGS "/MD")
endif()

list(APPEND NMAKE_OPTIONS_REL
    ${NMAKE_OPTIONS}
    CXX_CRT_FLAGS=${LINKAGE_FLAGS}
    PROJ_LIBRARY=${PROJ_LIBRARY_REL}
    PNG_LIB=${PNG_LIBRARY_REL}
    GEOS_LIB=${GEOS_LIBRARY_REL}
    EXPAT_LIB=${EXPAT_LIBRARY_REL}
    "CURL_LIB=${CURL_LIBRARY_REL} wsock32.lib wldap32.lib winmm.lib"
    SQLITE_LIB=${SQLITE_LIBRARY_REL}
    PG_LIB=${PGSQL_LIBRARY_REL}
    OPENJPEG_LIB=${OPENJPEG_LIBRARY_REL}
    WEBP_LIBS=${WEBP_LIBRARY_REL}
    LIBXML2_LIB=${XML2_LIBRARY_REL}
)

list(APPEND NMAKE_OPTIONS_DBG
    ${NMAKE_OPTIONS}
    CXX_CRT_FLAGS="${LINKAGE_FLAGS}d"
    PROJ_LIBRARY=${PROJ_LIBRARY_DBG}
    PNG_LIB=${PNG_LIBRARY_DBG}
    GEOS_LIB=${GEOS_LIBRARY_DBG}
    EXPAT_LIB=${EXPAT_LIBRARY_DBG}
    "CURL_LIB=${CURL_LIBRARY_DBG} wsock32.lib wldap32.lib winmm.lib"
    SQLITE_LIB=${SQLITE_LIBRARY_DBG}
    PG_LIB=${PGSQL_LIBRARY_DBG}
    OPENJPEG_LIB=${OPENJPEG_LIBRARY_DBG}
    WEBP_LIBS=${WEBP_LIBRARY_DBG}
    LIBXML2_LIB=${XML2_LIBRARY_DBG}
    DEBUG=1
)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  ################
  # Release build
  ################
  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc
    "${NMAKE_OPTIONS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
  )
  message(STATUS "Building ${TARGET_TRIPLET}-rel done")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  ################
  # Debug build
  ################
  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_required_process(
    COMMAND ${NMAKE} /G -f makefile.vc
    "${NMAKE_OPTIONS_DBG}"
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
  )
  message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
endif()

message(STATUS "Packaging ${TARGET_TRIPLET}")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gdal/html)

vcpkg_execute_required_process(
  COMMAND ${NMAKE} -f makefile.vc
  "${NMAKE_OPTIONS_REL}"
  "install"
  "devinstall"
  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
  LOGNAME nmake-install-${TARGET_TRIPLET}
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal_i.lib)

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY ${SOURCE_PATH_RELEASE}/gdal.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY ${SOURCE_PATH_DEBUG}/gdal.lib   DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
  endif()
else()

  set(GDAL_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/gdal)
  file(MAKE_DIRECTORY ${GDAL_TOOL_PATH})

  file(GLOB GDAL_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
  file(COPY ${GDAL_TOOLS} DESTINATION ${GDAL_TOOL_PATH})
  file(REMOVE_RECURSE ${GDAL_TOOLS})

  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/lib/gdal.lib)
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY ${SOURCE_PATH_DEBUG}/gdal${GDAL_VERSION_LIB}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${SOURCE_PATH_DEBUG}/gdal_i.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdald.lib)
  endif()
endif()

# Copy over PDBs
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH_RELEASE}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/gdal/copyright COPYONLY)
