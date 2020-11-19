include(${CMAKE_CURRENT_LIST_DIR}/dependency_win.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/dependency_unix.cmake)

vcpkg_fail_port_install(ON_ARCH "arm")

# NOTE: update the version and checksum for new GDAL release
set(GDAL_VERSION_STR "3.1.3")
set(GDAL_VERSION_PKG "313")
set(GDAL_VERSION_LIB "204")
set(GDAL_PACKAGE_SUM "a6dad37813eecb5e0c888ec940cf7f83c5096e69e4f33a3e5a5557542e7f656b9726e470e1b5d3d035de53df065510931a436a8c889f1366abd630c1cf5dfb49")

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/gdal/${GDAL_VERSION_STR}/gdal${GDAL_VERSION_PKG}.zip"
    FILENAME "gdal${GDAL_VERSION_PKG}.zip"
    SHA512 ${GDAL_PACKAGE_SUM}
)

set(GDAL_PATCHES 0001-Fix-debug-crt-flags.patch 0002-Fix-build.patch)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND GDAL_PATCHES 0003-Fix-static-build.patch)
endif()
list(APPEND GDAL_PATCHES 0004-Fix-std-fabs.patch 0005-Fix-cfitsio.patch)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES ${GDAL_PATCHES}
)

if (VCPKG_TARGET_IS_WINDOWS)
  set(NATIVE_DATA_DIR "${CURRENT_PACKAGES_DIR}/share/gdal")
  set(NATIVE_HTML_DIR "${CURRENT_PACKAGES_DIR}/share/gdal/html")

  find_dependency_win()

  if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
      list(APPEND NMAKE_OPTIONS MYSQL_INC_DIR=${MYSQL_INCLUDE_DIR})
      list(APPEND NMAKE_OPTIONS_REL MYSQL_LIB=${MYSQL_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG MYSQL_LIB=${MYSQL_LIBRARY_DBG})
  endif()

  list(APPEND NMAKE_OPTIONS
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
      list(APPEND NMAKE_OPTIONS DLLBUILD=0)
      list(APPEND NMAKE_OPTIONS "PROJ_FLAGS=-DPROJ_STATIC -DPROJ_VERSION=5")
  else()
      # Enables PDBs for release and debug builds
      list(APPEND NMAKE_OPTIONS WITH_PDB=1)
      list(APPEND NMAKE_OPTIONS DLLBUILD=1)
  endif()

  if (VCPKG_CRT_LINKAGE STREQUAL static)
      set(LINKAGE_FLAGS "/MT")
  else()
      set(LINKAGE_FLAGS "/MD")
  endif()

  list(APPEND NMAKE_OPTIONS_REL
      ${NMAKE_OPTIONS}
      GDAL_HOME=${CURRENT_PACKAGES_DIR}
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
      GDAL_HOME=${CURRENT_PACKAGES_DIR}/debug
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
  vcpkg_install_nmake(
    SOURCE_PATH ${SOURCE_PATH}
    TARGET devinstall
    OPTIONS_RELEASE
        "${NMAKE_OPTIONS_REL}"
    OPTIONS_DEBUG
        "${NMAKE_OPTIONS_DBG}"
  )

  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gdal/html)
  endif()

  if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND GDAL_EXES
        gdal_contour
        gdal_grid
        gdal_rasterize
        gdal_translate
        gdal_viewshed
        gdaladdo
        gdalbuildvrt
        gdaldem
        gdalenhance
        gdalinfo
        gdallocationinfo
        gdalmanage
        gdalmdiminfo
        gdalmdimtranslate
        gdalserver
        gdalsrsinfo
        gdaltindex
        gdaltransform
        gdalwarp
        gnmanalyse
        gnmmanage
        nearblack
        ogr2ogr
        ogrinfo
        ogrlineref
        ogrtindex
        testepsg
    )
    vcpkg_copy_tools(TOOL_NAMES ${GDAL_EXES} AUTO_CLEAN)
  else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
  endif()
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/share/gdal/html)

  vcpkg_copy_pdbs()
  
  if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/gdal204.pdb)
  endif()

else()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(BUILD_DYNAMIC yes)
        set(BUILD_STATIC no)
    else()
        set(BUILD_DYNAMIC no)
        set(BUILD_STATIC yes)
    endif()
    
    set(CONF_OPTS --enable-shared=${BUILD_DYNAMIC} --enable-static=${BUILD_STATIC})
    list(APPEND CONF_OPTS --with-proj=${CURRENT_INSTALLED_DIR} --with-libjson-c=${CURRENT_INSTALLED_DIR})
    
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        COPY_SOURCE
        OPTIONS ${CONF_OPTS}
        OPTIONS_DEBUG
            --enable-debug
            --without-fit # Disable cfitsio temporary
    )
    
    vcpkg_install_make(MAKEFILE GNUmakefile)
    
    file(REMOVE_RECURSE
         ${CURRENT_PACKAGES_DIR}/lib/gdalplugins
         ${CURRENT_PACKAGES_DIR}/debug/lib/gdalplugins
         ${CURRENT_PACKAGES_DIR}/debug/share
    )
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
