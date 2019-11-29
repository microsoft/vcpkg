vcpkg_fail_port_install(ON_ARCH "arm" "arm64")

set(GDAL_VERSION_STR "2.4.1")
set(GDAL_VERSION_PKG "241")
set(GDAL_VERSION_LIB "204")
set(GDAL_PACKAGE_SUM "edb9679ee6788334cf18971c803615ac9b1c72bc0c96af8fd4852cb7e8f58e9c4f3d9cb66406bc8654419612e1a7e9d0e62f361712215f4a50120f646bb0a738")

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/gdal/${GDAL_VERSION_STR}/gdal${GDAL_VERSION_PKG}.zip"
    FILENAME "gdal${GDAL_VERSION_PKG}.zip"
    SHA512 ${GDAL_PACKAGE_SUM}
)

list(APPEND GDAL_PATCHES 0001-Fix-debug-crt-flags.patch)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND GDAL_PATCHES  0002-Fix-static-build.patch)
endif()
list(APPEND GDAL_PATCHES
            0003-Fix-std-fabs.patch
            0004-fix-linux-build.patch
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES ${GDAL_PATCHES}
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(NATIVE_PACKAGES_DIR_DBG "${CURRENT_PACKAGES_DIR}")
    set(NATIVE_PACKAGES_DIR_REL "${CURRENT_PACKAGES_DIR}/debug")
    # We can't pass in the normal absolute path because the "xcopy" command needs to use the windows path.
    # We also can't pass in the windows path because it is used as an argument after the "\" will be used as an escape character and cannot be resolved using double quotes.
    # Use relative path here to install manually below
    set(NATIVE_DATA_DIR stage_data)
    set(NATIVE_HTML_DIR stage_html)
    
    set(COMMON_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")
    
    set(PROJ_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/proj.lib")
    set(PROJ_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/proj_d.lib")
    
    set(PNG_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libpng16.lib")
    set(PNG_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib")
    
    set(ZLIB_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/zlib.lib")
    set(ZLIB_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib")
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(GEOS_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libgeos_c.lib ${CURRENT_INSTALLED_DIR}/lib/libgeos.lib")
        set(GEOS_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libgeos_cd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libgeosd.lib")
    else()
        set(GEOS_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/geos_c.lib")
        set(GEOS_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/geos_cd.lib")
    endif()
    
    set(EXPAT_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/expat.lib")
    set(EXPAT_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/expat.lib")
    
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib")
      set(CURL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libcurl.lib")
    elseif(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib")
      set(CURL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libcurl_imp.lib")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib")
      set(CURL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d.lib")
    elseif(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib")
      set(CURL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libcurl-d_imp.lib")
    endif()
    
    set(SQLITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib")
    set(SQLITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib")
    
    set(PGSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libpq.lib")
    set(PGSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libpqd.lib")
    
    set(OPENJPEG_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/openjp2.lib")
    set(OPENJPEG_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/openjp2.lib")
    
    set(WEBP_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/webp.lib")
    set(WEBP_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/webpd.lib")
    
    set(XML2_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libxml2.lib")
    set(XML2_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libxml2.lib")
    
    set(LZMA_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/lzma.lib")
    set(LZMA_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/lzmad.lib")
    
    set(OPENSSL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libeay32.lib ${CURRENT_INSTALLED_DIR}/lib/ssleay32.lib")
    set(OPENSSL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libeay32.lib ${CURRENT_INSTALLED_DIR}/debug/lib/ssleay32.lib")
    
    set(ICONV_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libiconv.lib ${CURRENT_INSTALLED_DIR}/lib/libcharset.lib")
    set(ICONV_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libiconv.lib ${CURRENT_INSTALLED_DIR}/debug/lib/libcharset.lib")
    
    if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
        if("mysql-libmysql" IN_LIST FEATURES)
            set(MYSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libmysql.lib")
            set(MYSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libmysql.lib")
        endif()
    
        if("mysql-libmariadb" IN_LIST FEATURES)
            set(MYSQL_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/libmariadb.lib")
            set(MYSQL_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/libmariadb.lib")
        endif()
    
        list(APPEND NMAKE_OPTIONS MYSQL_INC_DIR=${CURRENT_INSTALLED_DIR}/include/mysql)
        list(APPEND NMAKE_OPTIONS_REL MYSQL_LIB=${MYSQL_LIBRARY_REL})
        list(APPEND NMAKE_OPTIONS_DBG MYSQL_LIB=${MYSQL_LIBRARY_DBG})
    endif()
    
    if ("libspatialite" IN_LIST FEATURES)
      set(SPATIALITE_LIBRARY_REL "${CURRENT_INSTALLED_DIR}/lib/spatialite.lib")
      set(SPATIALITE_LIBRARY_DBG "${CURRENT_INSTALLED_DIR}/debug/lib/spatialite.lib")
      set(HAVE_SPATIALITE "-DHAVE_SPATIALITE")
    endif()
    
    list(APPEND NMAKE_OPTIONS
        DATADIR=${NATIVE_DATA_DIR}
        HTMLDIR=${NATIVE_HTML_DIR}
        GEOS_DIR=${COMMON_INCLUDE_DIR}
        "GEOS_CFLAGS=-I${COMMON_INCLUDE_DIR} -DHAVE_GEOS"
        PROJ_INCLUDE=-I${COMMON_INCLUDE_DIR}
        EXPAT_DIR=${COMMON_INCLUDE_DIR}
        EXPAT_INCLUDE=-I${COMMON_INCLUDE_DIR}
        CURL_INC=-I${COMMON_INCLUDE_DIR}
        "SQLITE_INC=-I${COMMON_INCLUDE_DIR} ${HAVE_SPATIALITE}"
        PG_INC_DIR=${COMMON_INCLUDE_DIR}
        OPENJPEG_ENABLED=YES
        OPENJPEG_CFLAGS=-I${COMMON_INCLUDE_DIR}
        OPENJPEG_VERSION=20100
        WEBP_ENABLED=YES
        WEBP_CFLAGS=-I${COMMON_INCLUDE_DIR}
        LIBXML2_INC=-I${COMMON_INCLUDE_DIR}
        PNG_EXTERNAL_LIB=1
        PNGDIR=${COMMON_INCLUDE_DIR}
        ZLIB_INC=-I${COMMON_INCLUDE_DIR}
        ZLIB_EXTERNAL_LIB=1
        ACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1
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
    
    list(APPEND NMAKE_OPTIONS_REL
        GDAL_HOME=${NATIVE_PACKAGES_DIR_REL}
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
        GDAL_HOME=${NATIVE_PACKAGES_DIR_DBG}
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

    vcpkg_install_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        DISABLE_ALL
        OPTIONS ${NMAKE_OPTIONS}
        OPTIONS_DEBUG ${NMAKE_OPTIONS_DBG}
        OPTIONS_RELEASE ${NMAKE_OPTIONS_REL}
    )
    
    if (CMAKE_BUILD_TYPE STREQUAL debug)
        set(GDAL_OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    else()
        set(GDAL_OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    endif()
    
    # install headers
    macro(install_hdrs SRC_PATH)
        # DO NOT use GLOB_RECURSE here because we don't need to install addtional files
        file(GLOB GDAL_HDRS ${SRC_PATH}/*.h)
        foreach (GDAL_HDR ${GDAL_HDRS})
            file(INSTALL ${GDAL_HDR} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
        endforeach()
    endmacro()
    install_hdrs(${GDAL_OBJ_DIR}/port)
    install_hdrs(${GDAL_OBJ_DIR}/gcore)
    install_hdrs(${GDAL_OBJ_DIR}/alg)
    install_hdrs(${GDAL_OBJ_DIR}/apps)
    install_hdrs(${GDAL_OBJ_DIR}/gnm)
    install_hdrs(${GDAL_OBJ_DIR}/ogr)
    install_hdrs(${GDAL_OBJ_DIR}/ogr/ogrsf_frmts)
    install_hdrs(${GDAL_OBJ_DIR}/frmts/vrt)
    install_hdrs(${GDAL_OBJ_DIR}/frmts/mem)
    install_hdrs(${GDAL_OBJ_DIR}/frmts/raw)
    
    #install libs
    file(GLOB DBG_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib)
    file(INSTALL ${DBG_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(GLOB REL_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib)
    file(INSTALL ${REL_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    
    # install data/html files
    file(GLOB DATA_FILES ${GDAL_OBJ_DIR}/${NATIVE_DATA_DIR}/*)
    foreach(DATA_FILE ${DATA_FILES})
        file(INSTALL ${DATA_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    endforeach()
    file(GLOB HTML_FILES ${GDAL_OBJ_DIR}/${NATIVE_HTML_DIR}/*)
    foreach(HTNL_FILE ${DATA_FILES})
        file(INSTALL ${HTNL_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/html)
    endforeach()
    
    # move tools
    file(GLOB GDAL_TOOLS_REL ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    foreach(GDAL_TOOL ${GDAL_TOOLS_REL})
        file(COPY ${GDAL_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(REMOVE ${GDAL_TOOL})
    endforeach()
    file(GLOB GDAL_TOOLS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${GDAL_TOOLS_DBG})
    
    vcpkg_copy_pdbs()
else()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(BUILD_DYNAMIC yes)
        set(BUILD_STATIC no)
    else()
        set(BUILD_DYNAMIC no)
        set(BUILD_STATIC yes)
    endif()
    
    vcpkg_use_system_ports(OUT_PORTS_OPTIONS EXTRA_OPTIONS
        PORTS
        proj
        png
        geos
        sqlite3
        curl
        expat
        openjpeg
        webp
        xml2
        liblzma
        netcdf
        hdf5
        libz
        crypto
        libtiff
        
        INVERTED_PORTS
        hdf4
        
        FEATURES
        mysql-libmariadb mysql
        libspatialite spatialite
        giflib gif
        jasper jasper
        xerces-c xerces
    )

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS ${EXTRA_OPTIONS}
            --with-proj5-api=yes
            --enable-shared=${BUILD_DYNAMIC}
            --enable-static=${BUILD_STATIC}
        OPTIONS_DEBUG
            --enable-debug
            --with-boost-lib-path=${CURRENT_INSTALLED_DIR}/debug/lib
        OPTIONS_RELEASE
            --with-boost-lib-path=${CURRENT_INSTALLED_DIR}/lib
    )
    
    vcpkg_install_make()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin
                        ${CURRENT_PACKAGES_DIR}/debug/etc
                        ${CURRENT_PACKAGES_DIR}/debug/include
                        ${CURRENT_PACKAGES_DIR}/debug/share
                        ${CURRENT_PACKAGES_DIR}/debug/lib/gdalplugins
                        ${CURRENT_PACKAGES_DIR}/lib/gdalplugins
    )
    
    file(GLOB GDAL_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*)
    foreach (GDAL_TOOL ${GDAL_TOOLS})
        file(INSTALL ${GDAL_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gdal)
        file(REMOVE ${GDAL_TOOL})
    endforeach()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
