macro(find_dependency_win)
  # Setup proj4 libraries + include path
  set(PROJ_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")
  set(PROJ_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/proj.lib")
  set(PROJ_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib")

  # Setup libpng libraries + include path
  set(PNG_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")
  set(PNG_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libpng16.lib" )
  set(PNG_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib" )

  # Setup zlib libraries + include path
  set(ZLIB_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(ZLIB_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/zlib.lib" )
  set(ZLIB_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib" )

  # Setup geos libraries + include path
  set(GEOS_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(GEOS_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib" )
  set(GEOS_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib" )
  
  # Setup expat libraries + include path
  set(EXPAT_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
      set(EXPAT_SUFFIX "MT")
    else()
      set(EXPAT_SUFFIX "MD")
    endif()
    set(EXPAT_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libexpat${EXPAT_SUFFIX}.lib" )
    set(EXPAT_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatd${EXPAT_SUFFIX}.lib" )
  else()
    set(EXPAT_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libexpat.lib" )
    set(EXPAT_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatd.lib" )
  endif()
  
  # Setup curl libraries + include path
  set(CURL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib")
    set(CURL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib" )
  elseif(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib")
    set(CURL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib" )
  endif()
  if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib")
    set(CURL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib" )
  elseif(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib")
    set(CURL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib" )
  endif()

  # Setup sqlite3 libraries + include path
  set(SQLITE_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(SQLITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib" )
  set(SQLITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib" )

  # Setup PostgreSQL libraries + include path
  set(PGSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(PGSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libpq.lib" )
  set(PGSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpq.lib" )
  
  set(TMP_REL "${CURRENT_INSTALLED_DIR}/lib/libpgcommon.lib" )
  set(TMP_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpgcommon.lib" )
  set(PGSQL_LIBRARY_REL "${PGSQL_LIBRARY_REL} ${TMP_REL}")
  set(PGSQL_LIBRARY_DBG "${PGSQL_LIBRARY_DBG} ${TMP_DBG}")

  set(TMP_REL "${CURRENT_INSTALLED_DIR}/lib/libpgport.lib" )
  set(TMP_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpgport.lib" )
  set(PGSQL_LIBRARY_REL "${PGSQL_LIBRARY_REL} ${TMP_REL}")
  set(PGSQL_LIBRARY_DBG "${PGSQL_LIBRARY_DBG} ${TMP_DBG}")

  # Setup OpenJPEG libraries + include path
  set(OPENJPEG_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(OPENJPEG_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/openjp2.lib" )
  set(OPENJPEG_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/openjp2.lib" )

  # Setup WebP libraries + include path
  set(WEBP_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(WEBP_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/webp.lib" )
  set(WEBP_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/webpd.lib" )

  # Setup libxml2 libraries + include path
  set(XML2_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(XML2_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib" )
  set(XML2_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib" )

  # Setup liblzma libraries + include path
  set(LZMA_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  set(LZMA_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/lzma.lib" )
  set(LZMA_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib" )

  # Setup openssl libraries path
  set(OPENSSL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libcrypto.lib ${CURRENT_INSTALLED_DIR}/lib/libssl.lib" )
  set(OPENSSL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libcrypto.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libssl.lib" )

  # Setup libiconv libraries path
  set(ICONV_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/iconv.lib ${CURRENT_INSTALLED_DIR}/lib/charset.lib" )
  set(ICONV_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/iconv.lib ${CURRENT_INSTALLED_DIR}/debug/lib/charset.lib" )

  if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
      # Setup MySQL libraries + include path
      if("mysql-libmysql" IN_LIST FEATURES)
          set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql" )
          set(MYSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libmysql.lib" )
          set(MYSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libmysql.lib" )
      endif()

      if("mysql-libmariadb" IN_LIST FEATURES)
          set(MYSQL_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/mysql" )
          set(MYSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libmariadb.lib" )
          set(MYSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libmariadb.lib" )
      endif()
  endif()

  if ("libspatialite" IN_LIST FEATURES)
    # Setup spatialite libraries + include path
    set(SPATIALITE_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include/spatialite" )
    set(SPATIALITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib" )
    set(SPATIALITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib" )
    set(HAVE_SPATIALITE "-DHAVE_SPATIALITE")
  endif()
endmacro()