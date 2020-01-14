# vcpkg portfile.cmake for GDAL
#
# NOTE: update the version and checksum for new GDAL release
include(vcpkg_common_functions)

set(GDAL_VERSION_STR "2.4.1")
set(GDAL_VERSION_PKG "241")
set(GDAL_VERSION_LIB "204")
set(GDAL_PACKAGE_SUM "edb9679ee6788334cf18971c803615ac9b1c72bc0c96af8fd4852cb7e8f58e9c4f3d9cb66406bc8654419612e1a7e9d0e62f361712215f4a50120f646bb0a738")

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/gdal/${GDAL_VERSION_STR}/gdal${GDAL_VERSION_PKG}.zip"
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
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
      vcpkg_apply_patches(
          SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/gdal-${GDAL_VERSION_STR}
          PATCHES
                0001-Fix-debug-crt-flags.patch
                0002-Fix-static-build.patch
      )
    else()
      vcpkg_apply_patches(
          SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/gdal-${GDAL_VERSION_STR}
          PATCHES
                0001-Fix-debug-crt-flags.patch
      )
    endif()
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/gdal-${GDAL_VERSION_STR}/ogr
        PATCHES
              0003-Fix-std-fabs.patch
    )
endforeach()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  # Check build system first
  find_program(NMAKE nmake REQUIRED)

  file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" NATIVE_PACKAGES_DIR)
  file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal" NATIVE_DATA_DIR)
  file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/gdal/html" NATIVE_HTML_DIR)

  # Setup proj4 libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PROJ_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/proj.lib" PROJ_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib" PROJ_LIBRARY_DBG)

  # Setup libpng libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PNG_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpng16.lib" PNG_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib" PNG_LIBRARY_DBG)

  # Setup zlib libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" ZLIB_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/zlib.lib" ZLIB_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib" ZLIB_LIBRARY_DBG)

  # Setup geos libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" GEOS_INCLUDE_DIR)
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libgeos_c.lib ${CURRENT_INSTALLED_DIR}/lib/libgeos.lib" GEOS_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libgeos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libgeosd.lib" GEOS_LIBRARY_DBG)
  else()
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib" GEOS_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib" GEOS_LIBRARY_DBG)
  endif()

  # Setup expat libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" EXPAT_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/expat.lib" EXPAT_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/expat.lib" EXPAT_LIBRARY_DBG)

  # Setup curl libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" CURL_INCLUDE_DIR)
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib" CURL_LIBRARY_REL)
  elseif(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib" CURL_LIBRARY_REL)
  endif()
  if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib" CURL_LIBRARY_DBG)
  elseif(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib" CURL_LIBRARY_DBG)
  endif()

  # Setup sqlite3 libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" SQLITE_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib" SQLITE_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib" SQLITE_LIBRARY_DBG)

  # Setup PostgreSQL libraries + include path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PGSQL_INCLUDE_DIR)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpq.lib" PGSQL_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpq.lib" PGSQL_LIBRARY_DBG)
  
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpgcommon.lib" TMP_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpgcommon.lib" TMP_DBG)
  set(PGSQL_LIBRARY_REL "${PGSQL_LIBRARY_REL} ${TMP_REL}")
  set(PGSQL_LIBRARY_DBG "${PGSQL_LIBRARY_DBG} ${TMP_DBG}")

  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libpgport.lib" TMP_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libpgport.lib" TMP_DBG)
  set(PGSQL_LIBRARY_REL "${PGSQL_LIBRARY_REL} ${TMP_REL}")
  set(PGSQL_LIBRARY_DBG "${PGSQL_LIBRARY_DBG} ${TMP_DBG}")

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
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib" LZMA_LIBRARY_DBG)

  # Setup openssl libraries path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libcrypto.lib ${CURRENT_INSTALLED_DIR}/lib/libssl.lib" OPENSSL_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libcrypto.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libssl.lib" OPENSSL_LIBRARY_DBG)

  # Setup libiconv libraries path
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/libiconv.lib ${CURRENT_INSTALLED_DIR}/lib/libcharset.lib" ICONV_LIBRARY_REL)
  file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/libiconv.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libcharset.lib" ICONV_LIBRARY_DBG)

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

  if ("libspatialite" IN_LIST FEATURES)
    # Setup spatialite libraries + include path
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include/spatialite" SPATIALITE_INCLUDE_DIR)
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib" SPATIALITE_LIBRARY_REL)
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib" SPATIALITE_LIBRARY_DBG)
    set(HAVE_SPATIALITE "-DHAVE_SPATIALITE")
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
      "SQLITE_INC=-I${SQLITE_INCLUDE_DIR} ${HAVE_SPATIALITE}"
      PG_INC_DIR=${PGSQL_INCLUDE_DIR}
      OPENJPEG_ENABLED=YES
      OPENJPEG_CFLAGS=-I${OPENJPEG_INCLUDE_DIR}
      OPENJPEG_VERSION=20100
      WEBP_ENABLED=YES
      WEBP_CFLAGS=-I${WEBP_INCLUDE_DIR}
      LIBXML2_INC=-I${XML2_INCLUDE_DIR}
      PNG_EXTERNAL_LIB=1
      PNGDIR=${PNG_INCLUDE_DIR}
      ZLIB_INC=-I${ZLIB_INCLUDE_DIR}
      ZLIB_EXTERNAL_LIB=1
      ACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1
      MSVC_VER=1900
  )

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      list(APPEND NMAKE_OPTIONS WIN64=YES)
  endif()

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
      list(APPEND NMAKE_OPTIONS CURL_CFLAGS=-DCURL_STATICLIB)
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
      "GEOS_LIB=${GEOS_LIBRARY_REL}"
      EXPAT_LIB=${EXPAT_LIBRARY_REL}
      "CURL_LIB=${CURL_LIBRARY_REL} wsock32.lib wldap32.lib winmm.lib"
      "SQLITE_LIB=${SQLITE_LIBRARY_REL} ${SPATIALITE_LIBRARY_REL}"
      OPENJPEG_LIB=${OPENJPEG_LIBRARY_REL}
      WEBP_LIBS=${WEBP_LIBRARY_REL}
      "LIBXML2_LIB=${XML2_LIBRARY_REL} ${ICONV_LIBRARY_REL} ${LZMA_LIBRARY_REL}"
      ZLIB_LIB=${ZLIB_LIBRARY_REL}
      "PG_LIB=${PGSQL_LIBRARY_REL} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_REL}"
  )

  list(APPEND NMAKE_OPTIONS_DBG
      ${NMAKE_OPTIONS}
      CXX_CRT_FLAGS="${LINKAGE_FLAGS}d"
      PROJ_LIBRARY=${PROJ_LIBRARY_DBG}
      PNG_LIB=${PNG_LIBRARY_DBG}
      "GEOS_LIB=${GEOS_LIBRARY_DBG}"
      EXPAT_LIB=${EXPAT_LIBRARY_DBG}
      "CURL_LIB=${CURL_LIBRARY_DBG} wsock32.lib wldap32.lib winmm.lib"
      "SQLITE_LIB=${SQLITE_LIBRARY_DBG} ${SPATIALITE_LIBRARY_DBG}"
      OPENJPEG_LIB=${OPENJPEG_LIBRARY_DBG}
      WEBP_LIBS=${WEBP_LIBRARY_DBG}
      "LIBXML2_LIB=${XML2_LIBRARY_DBG} ${ICONV_LIBRARY_DBG} ${LZMA_LIBRARY_DBG}"
      ZLIB_LIB=${ZLIB_LIBRARY_DBG}
      "PG_LIB=${PGSQL_LIBRARY_DBG} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_DBG}"
      DEBUG=1
  )
  
  # Begin build process
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

  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gdal/html)
  endif()

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

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
      file(COPY ${SOURCE_PATH_RELEASE}/gdal_i.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      file(COPY ${SOURCE_PATH_DEBUG}/gdal_i.lib   DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
      file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gdal_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gdal_id.lib)
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
  
  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal204.pdb)
  endif()

elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin") # Build in UNIX
  # Check build system first
  find_program(MAKE make)
  if (NOT MAKE)
      message(FATAL_ERROR "MAKE not found")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    ################
    # Release build
    ################
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    set(OUT_PATH_RELEASE ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
    file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE}
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME config-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
      COMMAND make -j ${VCPKG_CONCURRENCY}
      NO_PARALLEL_COMMAND make
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME make-build-${TARGET_TRIPLET}-release
    )

    message(STATUS "Installing ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
      COMMAND make install
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME make-install-${TARGET_TRIPLET}-release
    )

    file(REMOVE_RECURSE ${OUT_PATH_RELEASE}/lib/gdalplugins)
    file(COPY ${OUT_PATH_RELEASE}/lib/pkgconfig DESTINATION ${OUT_PATH_RELEASE}/share/gdal)
    file(REMOVE_RECURSE ${OUT_PATH_RELEASE}/lib/pkgconfig)
    file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
    file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
    file(COPY ${OUT_PATH_RELEASE}/share DESTINATION ${CURRENT_PACKAGES_DIR})
    message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    ################
    # Debug build
    ################
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    set(OUT_PATH_DEBUG ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-debug)
    file(MAKE_DIRECTORY ${OUT_PATH_DEBUG})
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_DEBUG}/configure" --prefix=${OUT_PATH_DEBUG}
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME config-${TARGET_TRIPLET}-debug
    )

    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_build_process(
      COMMAND make -j ${VCPKG_CONCURRENCY}
      NO_PARALLEL_COMMAND make
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME make-build-${TARGET_TRIPLET}-debug
    )

    message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
      COMMAND make -j install
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME make-install-${TARGET_TRIPLET}-debug
    )

    file(REMOVE_RECURSE ${OUT_PATH_DEBUG}/lib/gdalplugins)
    file(REMOVE_RECURSE ${OUT_PATH_DEBUG}/lib/pkgconfig)
    file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
    message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
  endif()
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

# Handle copyright
configure_file(${SOURCE_PATH_RELEASE}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/gdal/copyright COPYONLY)
