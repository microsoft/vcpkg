set(GDAL_PATCHES
    0001-Fix-debug-crt-flags.patch
    0002-Fix-build.patch
    0004-Fix-cfitsio.patch
    0005-Fix-configure.patch
    0007-Control-tools.patch
    0008-Fix-absl-string_view.patch
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND GDAL_PATCHES 0006-Fix-mingw-dllexport.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/gdal
    REF d699b38a744301368070ef780f797340da4a9c3c # 3.4.0
    SHA512 709523740a51a0a2a144debcfa5fbc5a5b3d93cc3632856cfbc37f7ca52f2e83f4942d9a27d4c723ee19d2397cc91a4b1ba4543547afdfefb3980a7ba6684bd7
    HEAD_REF master
    PATCHES ${GDAL_PATCHES}
)
# `vcpkg clean` stumbles over one subdir
file(REMOVE_RECURSE "${SOURCE_PATH}/autotest")

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(NATIVE_DATA_DIR "${CURRENT_PACKAGES_DIR}/share/gdal")
    set(NATIVE_HTML_DIR "${CURRENT_PACKAGES_DIR}/share/gdal/html")

    set(NMAKE_OPTIONS "")
    set(NMAKE_OPTIONS_REL "")
    set(NMAKE_OPTIONS_DBG "")

    x_vcpkg_pkgconfig_get_modules(PREFIX PROJ MODULES --msvc-syntax proj INCLUDE_DIRS LIBS)

    include("${CMAKE_CURRENT_LIST_DIR}/dependency_win.cmake")
    find_dependency_win()

    if("mysql-libmysql" IN_LIST FEATURES OR "mysql-libmariadb" IN_LIST FEATURES)
        list(APPEND NMAKE_OPTIONS "MYSQL_INC_DIR=${MYSQL_INCLUDE_DIR}")
        list(APPEND NMAKE_OPTIONS_REL "MYSQL_LIB=${MYSQL_LIBRARY_REL}")
        list(APPEND NMAKE_OPTIONS_DBG "MYSQL_LIB=${MYSQL_LIBRARY_DBG}")
    endif()

    list(APPEND NMAKE_OPTIONS
        "DATADIR=${NATIVE_DATA_DIR}"
        "HTMLDIR=${NATIVE_HTML_DIR}"
        "GEOS_DIR=${GEOS_INCLUDE_DIR}"
        "GEOS_CFLAGS=-I${GEOS_INCLUDE_DIR} -DHAVE_GEOS"
        "PROJ_INCLUDE=${PROJ_INCLUDE_DIRS}"
        "EXPAT_DIR=${EXPAT_INCLUDE_DIR}"
        "EXPAT_INCLUDE=-I${EXPAT_INCLUDE_DIR}"
        "CURL_INC=-I${CURL_INCLUDE_DIR}"
        "SQLITE_INC=-I${SQLITE_INCLUDE_DIR} ${HAVE_SPATIALITE}"
        "PG_INC_DIR=${PGSQL_INCLUDE_DIR}"
        OPENJPEG_ENABLED=YES
        "OPENJPEG_CFLAGS=-I${OPENJPEG_INCLUDE_DIR}"
        OPENJPEG_VERSION=20100
        WEBP_ENABLED=YES
        "WEBP_CFLAGS=-I${WEBP_INCLUDE_DIR}"
        "LIBXML2_INC=-I${XML2_INCLUDE_DIR}"
        PNG_EXTERNAL_LIB=1
        "PNGDIR=${PNG_INCLUDE_DIR}"
        "ZLIB_INC=-I${ZLIB_INCLUDE_DIR}"
        ZLIB_EXTERNAL_LIB=1
        MSVC_VER=1900
        )

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        list(APPEND NMAKE_OPTIONS WIN64=YES)
    endif()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
        list(APPEND NMAKE_OPTIONS SSEFLAGS=/DNO_SSSE AVXFLAGS=/DNO_AVX)
    endif()

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND NMAKE_OPTIONS CURL_CFLAGS=-DCURL_STATICLIB)
        list(APPEND NMAKE_OPTIONS DLLBUILD=0)
        list(APPEND NMAKE_OPTIONS "PROJ_FLAGS=-DPROJ_STATIC -DPROJ_VERSION=5")
    else()
        # Enables PDBs for release and debug builds
        list(APPEND NMAKE_OPTIONS WITH_PDB=1)
        list(APPEND NMAKE_OPTIONS DLLBUILD=1)
    endif()

    if (VCPKG_CRT_LINKAGE STREQUAL "static")
        set(LINKAGE_FLAGS "/MT")
    else()
        set(LINKAGE_FLAGS "/MD")
    endif()

    list(APPEND NMAKE_OPTIONS_REL
        ${NMAKE_OPTIONS}
        "GDAL_HOME=${CURRENT_PACKAGES_DIR}"
        "CXX_CRT_FLAGS=${LINKAGE_FLAGS}"
        "PROJ_LIBRARY=${PROJ_LIBS_RELEASE}"
        "PNG_LIB=${PNG_LIBRARY_REL}"
        "GEOS_LIB=${GEOS_LIBRARY_REL}"
        "EXPAT_LIB=${EXPAT_LIBRARY_REL}"
        "CURL_LIB=${CURL_LIBRARY_REL} wsock32.lib wldap32.lib winmm.lib"
        "SQLITE_LIB=${SQLITE_LIBRARY_REL} ${SPATIALITE_LIBRARY_REL}"
        "OPENJPEG_LIB=${OPENJPEG_LIBRARY_REL}"
        "WEBP_LIBS=${WEBP_LIBRARY_REL}"
        "LIBXML2_LIB=${XML2_LIBRARY_REL} ${ICONV_LIBRARY_REL} ${LZMA_LIBRARY_REL}"
        "ZLIB_LIB=${ZLIB_LIBRARY_REL}"
        "PG_LIB=${PGSQL_LIBRARY_REL} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_REL}"
        )

    list(APPEND NMAKE_OPTIONS_DBG
        ${NMAKE_OPTIONS}
        "GDAL_HOME=${CURRENT_PACKAGES_DIR}/debug"
        "CXX_CRT_FLAGS=${LINKAGE_FLAGS}d"
        "PROJ_LIBRARY=${PROJ_LIBS_DEBUG}"
        "PNG_LIB=${PNG_LIBRARY_DBG}"
        "GEOS_LIB=${GEOS_LIBRARY_DBG}"
        "EXPAT_LIB=${EXPAT_LIBRARY_DBG}"
        "CURL_LIB=${CURL_LIBRARY_DBG} wsock32.lib wldap32.lib winmm.lib"
        "SQLITE_LIB=${SQLITE_LIBRARY_DBG} ${SPATIALITE_LIBRARY_DBG}"
        "OPENJPEG_LIB=${OPENJPEG_LIBRARY_DBG}"
        "WEBP_LIBS=${WEBP_LIBRARY_DBG}"
        "LIBXML2_LIB=${XML2_LIBRARY_DBG} ${ICONV_LIBRARY_DBG} ${LZMA_LIBRARY_DBG}"
        "ZLIB_LIB=${ZLIB_LIBRARY_DBG}"
        "PG_LIB=${PGSQL_LIBRARY_DBG} Secur32.lib Shell32.lib Advapi32.lib Crypt32.lib Gdi32.lib ${OPENSSL_LIBRARY_DBG}"
        DEBUG=1
        )

    if("tools" IN_LIST FEATURES)
        list(APPEND NMAKE_OPTIONS_REL "BUILD_TOOLS=1")
    else()
        list(APPEND NMAKE_OPTIONS_REL "BUILD_TOOLS=0")
    endif()
    list(APPEND NMAKE_OPTIONS_DBG "BUILD_TOOLS=0")

    # Begin build process
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}/gdal"
        TARGET devinstall
        OPTIONS_RELEASE
        "${NMAKE_OPTIONS_REL}"
        OPTIONS_DEBUG
        "${NMAKE_OPTIONS_DBG}"
        )

    if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/gdal/html")
    endif()

    if("tools" IN_LIST FEATURES)
        set(GDAL_EXES
            gdal_contour
            gdal_create
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
            )
        # vcpkg_copy_tools removed the bin directories for us so no need to remove again
        vcpkg_copy_tools(TOOL_NAMES ${GDAL_EXES} AUTO_CLEAN)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/share/gdal/html")

    vcpkg_copy_pdbs()

    if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/gdal204.pdb")
    endif()

else()
    # See https://github.com/microsoft/vcpkg/issues/16990
    file(TOUCH "${SOURCE_PATH}/gdal/config.rpath")

    set(CONF_OPTS
        --with-gnm=yes
        --with-hide-internal-symbols=yes
        --with-java=no
        --with-perl=no
        --with-python=no
        )
    set(CONF_CHECKS "")
    function(add_config option check)
        list(APPEND CONF_OPTS "${option}")
        set(CONF_OPTS "${CONF_OPTS}" PARENT_SCOPE)
        list(APPEND CONF_CHECKS "${check}")
        set(CONF_CHECKS "${CONF_CHECKS}" PARENT_SCOPE)
    endfunction()
    # parameters in the same order as the dependencies in vcpkg.json
    add_config("--with-curl=yes"     "cURL support .wms/wcs/....:yes")
    add_config("--with-expat=yes"    "Expat support:             yes")
    add_config("--with-geos=yes"     "GEOS support:              yes")
    add_config("--with-gif=yes"      "LIBGIF support:            external")
    add_config("--with-libjson=yes"  "checking for JSONC... yes")
    add_config("--with-geotiff=yes"  "LIBGEOTIFF support:        external")
    add_config("--with-jpeg=yes"     "LIBJPEG support:           external")
    add_config("--with-liblzma=yes"  "LIBLZMA support:           yes")
    add_config("--with-png=yes"      "LIBPNG support:            external")
    add_config("--with-webp=yes"     "WebP support:              yes")
    add_config("--with-xml2=yes"     "libxml2 support:           yes")
    add_config("--with-openjpeg=yes" "OpenJPEG support:          yes")
    add_config("--with-proj=yes"     "PROJ >= 6:                 yes")
    add_config("--with-sqlite3=yes"  "SQLite support:            yes")
    add_config("--with-libtiff=yes"  "LIBTIFF support:           external")
    add_config("--with-libz=yes"     "LIBZ support:              external")
    add_config("--with-zstd=yes"     "ZSTD support:              yes")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND CONF_OPTS --without-libtool --without-ld-shared)
    endif()

    if("system-libraries" IN_LIST FEATURES)
        set(DISABLE_SYSTEM_LIBRARIES OFF)
    else()
        set(DISABLE_SYSTEM_LIBRARIES ON)
    endif()

    if ("libspatialite" IN_LIST FEATURES)
        add_config("--with-spatialite=yes"  "SpatiaLite support:        yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-spatialite=no"   "SpatiaLite support:        no")
    endif()

    if ("postgresql" IN_LIST FEATURES)
        add_config("--with-pg=yes"  "PostgreSQL support:        yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-pg=no"   "PostgreSQL support:        no")
    endif()

    if ("mysql-libmariadb" IN_LIST FEATURES)
        add_config("--with-mysql=yes"  "MySQL support:             yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-mysql=no"   "MySQL support:             no")
    endif()

    if ("cfitsio" IN_LIST FEATURES)
        add_config("--with-cfitsio=yes"  "CFITSIO support:           external")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-cfitsio=no"   "CFITSIO support:           no")
    endif()

    if ("hdf5" IN_LIST FEATURES)
        add_config("--with-hdf5=yes"     "HDF5 support:              yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-hdf5=no"      "HDF5 support:              no")
    endif()

    if ("netcdf" IN_LIST FEATURES)
        add_config("--with-netcdf=yes"   "NetCDF support:            yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-netcdf=no"    "NetCDF support:            no")
    endif()

    if(DISABLE_SYSTEM_LIBRARIES)
        list(APPEND CONF_OPTS
            # Too much: --disable-all-optional-drivers
            # alphabetical order
            --with-armadillo=no
            --with-blosc=no
            --with-brunsli=no
            --with-charls=no
            --with-crypto=no
            --with-cryptopp=no
            --with-dds=no
            --with-dods-root=no
            --with-ecw=no
            --with-epsilon=no
            --with-exr=no
            --with-fgdb=no
            --with-fme=no
            --with-freexl=no
            --with-grass=no
            --with-gta=no
            --with-hdf4=no
            --with-hdfs=no
            --with-heif=no
            --with-idb=no
            --with-ingres=no
            --with-jp2lura=no
            --with-jp2mrsid=no
            --with-jasper=no
            --with-jxl=no
            --with-kakadu=no
            --with-kea=no
            --with-lerc=no
            --with-libdeflate=no
            --with-libgrass=no
            --with-libkml=no
            --with-lz4=no
            --with-mdb=no
            --with-mongocxx=no
            --with-mongocxxv3=no
            --with-mrsid=no
            --with-mrsid_lidar=no
            --with-msg=no
            --with-null=no
            --with-oci=no
            --with-odbc=no
            --with-ogdi=no
            --with-opencl=no
            --with-pcidsk=no
            --with-pcraster=no
            --with-pcre=no
            --with-pdfium=no
            --with-podofo=no
            --with-poppler=no
            --with-qhull=no
            --with-rasdaman=no
            --with-rasterlite2=no
            --with-rdb=no
            --with-sfcgal=no
            --with-sosi=no
            --with-teigha=no
            --with-tiledb=no
            --with-xerces=no
            )
    endif()

    x_vcpkg_pkgconfig_get_modules(PREFIX PROJ MODULES proj LIBS)

    if("tools" IN_LIST FEATURES)
        list(APPEND CONF_OPTS "--with-tools=yes")
    else()
        list(APPEND CONF_OPTS "--with-tools=no")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}/gdal"
        AUTOCONFIG
        COPY_SOURCE
        OPTIONS
            ${CONF_OPTS}
        OPTIONS_RELEASE
            "--with-proj-extra-lib-for-test=${PROJ_LIBS_RELEASE}"
        OPTIONS_DEBUG
            --enable-debug
            --with-tools=no
            "--with-proj-extra-lib-for-test=${PROJ_LIBS_DEBUG}"
        )

    # Verify configuration results (tightly coupled to vcpkg_configure_make)
    function(check_config logfile)
        set(failed_checks "")
        file(READ "${logfile}" log)
        foreach(check IN LISTS CONF_CHECKS)
            if(NOT log MATCHES "${check}")
                string(APPEND failed_checks "\n   ${check}")
            endif()
        endforeach()
        if(failed_checks)
            get_filename_component(file "${logfile}" NAME_WE)
            message(FATAL_ERROR "${file}: Configuration failed for ${failed_checks}")
        endif()
    endfunction()
    foreach(suffix IN ITEMS rel dbg)
        set(log "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-${suffix}-out.log")
        if(EXISTS "${log}")
            check_config("${log}")
        endif()
    endforeach()

    vcpkg_install_make(MAKEFILE GNUmakefile)

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/lib/gdalplugins"
        "${CURRENT_PACKAGES_DIR}/debug/lib/gdalplugins"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        )

    vcpkg_fixup_pkgconfig()
    set(pc_file_debug "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gdal.pc")
    if(EXISTS "${pc_file_debug}")
        vcpkg_replace_string("${pc_file_debug}" "${prefix}/../../include" "${prefix}/../include")
        vcpkg_replace_string("${pc_file_debug}" "${exec_prefix}/include" "${prefix}/../include")
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gdal/bin/gdal-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gdal/debug/bin/gdal-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpl_config.h" "#define GDAL_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/gdal/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
