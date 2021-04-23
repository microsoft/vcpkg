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
  set(GEOS_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib ${CURRENT_INSTALLED_DIR}/lib/geos.lib" )
  set(GEOS_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/geosd.lib" )
  
  # Setup expat libraries + include path
  set(EXPAT_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include" )
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(EXPAT_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libexpatMD.lib" )
    set(EXPAT_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libexpatdMD.lib" )
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

  # Setup jpeg libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/jpeg.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" JPEG_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/jpeg.lib" JPEG_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/jpegd.lib" JPEG_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS JPEG_EXTERNAL_LIB=1)
      list(APPEND NMAKE_OPTIONS JPEGDIR=${JPEG_INCLUDE})
      list(APPEND NMAKE_OPTIONS_REL JPEG_LIB=${JPEG_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG JPEG_LIB=${JPEG_LIBRARY_DBG})
  endif()

  # Setup zstd libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/zstd.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" ZSTD_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/zstd.lib" ZSTD_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/zstdd.lib" ZSTD_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS ZSTD_CFLAGS=-I${ZSTD_INCLUDE})
      list(APPEND NMAKE_OPTIONS_REL ZSTD_LIBS=${ZSTD_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG ZSTD_LIBS=${ZSTD_LIBRARY_DBG})
  endif()

  # Setup tiff libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/tiff.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" TIFF_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/tiff.lib" TIFF_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/tiffd.lib" TIFF_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS TIFF_INC=-I${TIFF_INCLUDE})
      list(APPEND NMAKE_OPTIONS TIFF_OPTS=-DBIGTIFF_SUPPORT)
      list(APPEND NMAKE_OPTIONS_REL TIFF_LIB=${TIFF_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG TIFF_LIB=${TIFF_LIBRARY_DBG})
  endif()

  # Setup geotiff libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/geotiff_i.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" GEOTIFF_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/geotiff_i.lib" GEOTIFF_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/geotiff_d_i.lib" GEOTIFF_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS GEOTIFF_INC=-I${GEOTIFF_INCLUDE})
      list(APPEND NMAKE_OPTIONS_REL GEOTIFF_LIB=${GEOTIFF_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG GEOTIFF_LIB=${GEOTIFF_LIBRARY_DBG})
  endif()

  # Setup Xerces libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/xerces-c_3.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" XERCES_DIR)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" XERCES_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/xerces-c_3.lib" XERCES_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/xerces-c_3D.lib" XERCES_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS ILI_ENABLED=YES)
      list(APPEND NMAKE_OPTIONS XERCES_DIR=${XERCES_DIR})
      list(APPEND NMAKE_OPTIONS "XERCES_INCLUDE=-I${XERCES_INCLUDE} -I${XERCES_INCLUDE}/xercesc")
      list(APPEND NMAKE_OPTIONS_REL XERCES_LIB=${XERCES_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG XERCES_LIB=${XERCES_LIBRARY_DBG})
  endif()

  # Setup freexl libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/freexl.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" FREEXL_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/freexl.lib" FREEXL_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/freexl.lib" FREEXL_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS FREEXL_CFLAGS=-I${FREEXL_INCLUDE})
      list(APPEND NMAKE_OPTIONS_REL FREEXL_LIBS=${FREEXL_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG FREEXL_LIBS=${FREEXL_LIBRARY_DBG})
  endif()

  # Setup Cryptopp libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/cryptopp-static.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" CRYPTOPP_INCLUDE)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/cryptopp-static.lib" CRYPTOPP_LIBRARY_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/cryptopp-static.lib" CRYPTOPP_LIBRARY_DBG)
      list(APPEND NMAKE_OPTIONS CRYPTOPP_INC=-I${CRYPTOPP_INCLUDE})
      list(APPEND NMAKE_OPTIONS_REL CRYPTOPP_LIB=${CRYPTOPP_LIBRARY_REL})
      list(APPEND NMAKE_OPTIONS_DBG CRYPTOPP_LIB=${CRYPTOPP_LIBRARY_DBG})
  endif()

  # Setup netcdf libraries
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/netcdf.lib")
          file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" NETCDF_INCLUDE)
          file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/netcdf.lib" NETCDF_LIBRARY_REL)
          file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/netcdf.lib" NETCDF_LIBRARY_DBG)
          list(APPEND NMAKE_OPTIONS NETCDF_PLUGIN=NO)
          list(APPEND NMAKE_OPTIONS NETCDF_SETTING=yes)
          list(APPEND NMAKE_OPTIONS NETCDF_INC_DIR=${NETCDF_INCLUDE})
          list(APPEND NMAKE_OPTIONS_REL NETCDF_LIB=${NETCDF_LIBRARY_REL})
          list(APPEND NMAKE_OPTIONS_DBG NETCDF_LIB=${NETCDF_LIBRARY_DBG})
      endif()
  endif()

  # Setup libkml libraries
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/kmlbase.lib")
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" LIBKML_DIR)
      list(APPEND NMAKE_OPTIONS LIBKML_DIR=${LIBKML_DIR})
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" LIBKML_INCLUDE)
      list(APPEND NMAKE_OPTIONS LIBKML_INCLUDE=-I${LIBKML_INCLUDE})
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmlbase.lib" KMLBASE_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmlbase.lib" KMLBASE_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmlconvenience.lib" KMLCONVENIENCE_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmlconvenience.lib" KMLCONVENIENCE_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmldom.lib" KMLDOM_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmldom.lib" KMLDOM_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmlengine.lib" KMLENGINE_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmlengine.lib" KMLENGINE_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmlregionator.lib" KMLREGIONATOR_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmlregionator.lib" KMLREGIONATOR_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/kmlxsd.lib" KMLXSD_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/kmlxsd.lib" KMLXSD_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/bz2.lib" BZIP2_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/bz2d.lib" BZIP2_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/minizip.lib" MINIZIP_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/minizip.lib" MINIZIP_DBG)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/uriparser.lib" URIPARSER_REL)
      file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/uriparser.lib" URIPARSER_DBG)
      list(APPEND NMAKE_OPTIONS_REL "LIBKML_LIBS=${KMLBASE_REL} ${KMLCONVENIENCE_REL} ${KMLDOM_REL} ${KMLENGINE_REL} ${KMLREGIONATOR_REL} ${KMLXSD_REL} ${BZIP2_REL} ${MINIZIP_REL} ${URIPARSER_REL} ${EXPAT_LIBRARY_REL} ${ZLIB_LIBRARY_REL}")
      list(APPEND NMAKE_OPTIONS_DBG "LIBKML_LIBS=${KMLBASE_DBG} ${KMLCONVENIENCE_DBG} ${KMLDOM_DBG} ${KMLENGINE_DBG} ${KMLREGIONATOR_DBG} ${KMLXSD_DBG} ${BZIP2_DBG} ${MINIZIP_DBG} ${URIPARSER_DBG} ${EXPAT_LIBRARY_DBG} ${ZLIB_LIBRARY_DBG}")
  endif()

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
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SPATIALITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/librttopo.lib" "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib")
        set(SPATIALITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/librttopo.lib" "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib")
    else()
        set(SPATIALITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib" )
        set(SPATIALITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib" )
    endif()
    set(HAVE_SPATIALITE "-DHAVE_SPATIALITE")
  endif()
endmacro()