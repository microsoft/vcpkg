vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/gdal
    REF v3.5.0RC2
    SHA512 19ebef4207d70217a83b0af4543a4cdb41fd3407d27012f462ff197e161d3eed23bd9919112d48271b8d0a637cc3c8ec4c2844385bd953143fed828f82723467
    HEAD_REF master
)
# `vcpkg clean` stumbles over one subdir
file(REMOVE_RECURSE "${SOURCE_PATH}/autotest")

if("primary-features" IN_LIST FEATURES)
    # Features which are not made explicit yet.
    list(APPEND FEATURES
        expat
        gif
        #hdf4
        #iconv
        jpeg
        #libcsf
        #lerc
        liblzma
        png
        libxml2
        #odbc
        #opencad
        openjpeg
        pcre2
        png
        #rasterlite
        #shapelib
        sqlite3
        webp
        #xerces-c
        zstd
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cfitsio         GDAL_USE_CFITSIO
        curl            GDAL_USE_CURL
        expat           GDAL_USE_EXPAT
        freexl          GDAL_USE_FREEXL
        geos            GDAL_USE_GEOS
        core            GDAL_USE_GEOTIFF
         NEVER           GDAL_USE_GEOTIFF_INTERNAL
        gif             GDAL_USE_GIF
         NEVER           GDAL_USE_GIF_INTERNAL
        hdf4            GDAL_USE_HDF4
        hdf4            GDAL_ENABLE_DRIVER_HDF4
        hdf5            GDAL_USE_HDF5
        core            GDAL_USE_ICONV # Always used if found.
        jpeg            GDAL_USE_JPEG
         NEVER           GDAL_USE_JPEG_INTERNAL
        core            GDAL_USE_JSONC #!
         NEVER           GDAL_USE_JSONC_INTERNAL #?
        libcsf          GDAL_USE_LIBCSF
         libcsf          GDAL_USE_LIBCSF_INTERNAL
        lerc            GDAL_USE_LERC
         NEVER           GDAL_USE_LERC_INTERNAL # affects capabilities of mrf raster driver
        liblzma         GDAL_USE_LIBLZMA
        libxml2         GDAL_USE_LIBXML2
        mysql-libmariadb  GDAL_USE_MYSQL 
        netcdf          GDAL_USE_NETCDF
        odbc            GDAL_USE_ODBC
        opencad         GDAL_USE_OPENCAD
         opencad         GDAL_USE_OPENCAD_INTERNAL
        openjpeg        GDAL_USE_OPENJPEG #?
        pcre2           GDAL_USE_PCRE2
        png             GDAL_USE_PNG
         NEVER           GDAL_USE_PNG_INTERNAL
        postgresql      GDAL_USE_POSTGRESQL
        core            GDAL_USE_QHULL
         NEVER           GDAL_USE_QHULL_INTERNAL
        rasterlite      GDAL_USE_RASTERLITE2
#         rasterlite      GDAL_ENABLE_DRIVER_RASTERLITE # HAVE_RASTERLITE
        shapelib        GDAL_USE_SHAPELIB
         NEVER           GDAL_USE_SHAPELIB_INTERNAL
        libspatialite   GDAL_USE_SPATIALITE
        sqlite3         GDAL_USE_SQLITE3
        core            GDAL_USE_TIFF
         NEVER           GDAL_USE_TIFF_INTERNAL
        webp            GDAL_USE_WEBP
        xerces-c        GDAL_USE_XERCESC
        core            GDAL_USE_ZLIB
         NEVER           GDAL_USE_ZLIB_INTERNAL
        zstd            GDAL_USE_ZSTD
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS -D_ICONV_SECOND_ARGUMENT_IS_NOT_CONST=ON)
endif()
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS_RELEASE
    FEATURES
        tools           BUILD_APPS
        tools           BUILD_TESTING
    INVERTED_FEATURES
        tools           CMAKE_DISABLE_FIND_PACKAGE_Python
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        ${FEATURE_OPTIONS}
        -DBUILD_DOCS=OFF
        -DBUILD_CSHARP_BINDINGS=OFF
        -DBUILD_JAVA_BINDINGS=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DGDAL_USE_EXTERNAL_LIBS=OFF
        -DGDAL_BUILD_OPTIONAL_DRIVERS=ON
        -DOGR_BUILD_OPTIONAL_DRIVERS=ON
        -DGDAL_CHECK_PACKAGE_NetCDF_NAMES=netCDF
        -DGDAL_CHECK_PACKAGE_NetCDF_TARGETS=netCDF::netcdf
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -DBUILD_TESTING=OFF
        -DBUILD_APPS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python=ON
    MAYBE_UNUSED_VARIABLES
        BUILD_CSHARP_BINDINGS # BUILD_SHARED_LIBS
        BUILD_JAVA_BINDINGS   # BUILD_SHARED_LIBS
        BUILD_PYTHON_BINDINGS # BUILD_SHARED_LIBS
        GDAL_USE_CRNLIB     # GDAL_ENABLE_DRIVER_DDS
        GDAL_USE_ECW        # GDAL_ENABLE_DRIVER_ECW
        GDAL_USE_FME        # GDAL_ENABLE_DRIVER_FME
        GDAL_USE_IDB        # GDAL_ENABLE_DRIVER_IDB
        GDAL_USE_MRSID      # GDAL_ENABLE_DRIVER_MRSID
        GDAL_USE_OGDI       # GDAL_ENABLE_DRIVER_OGDI
        GDAL_USE_OPENMP     # This option is "unused for now" in gdal's build system.
        GDAL_USE_ORACLE     # GDAL_ENABLE_DRIVER_GEOR, GDAL_ENABLE_DRIVER_OCI
        GDAL_USE_PCRE       # unused when GDAL_USE_PCRE2 is enabled
        GDAL_USE_RASDAMAN   # GDAL_ENABLE_DRIVER_RASDAMAN
 )
vcpkg_cmake_install()
vcpkg_copy_pdbs()
if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            gdalinfo
            gdalbuildvrt
            gdaladdo
            gdal_grid
            gdal_translate
            gdal_rasterize
            gdalsrsinfo
            gdalenhance
            gdalmanage
            gdaltransform
            gdaltindex
            gdaldem
            gdal_create
            gdal_viewshed
            nearblack
            ogrlineref
            ogrtindex
            gdalwarp
            gdal_contour
            gdallocationinfo
            ogrinfo
            ogr2ogr
            ogrlineref
            nearblack
            gdalmdiminfo
            gdalmdimtranslate
            gnmanalyse
            gnmmanage
        AUTO_CLEAN
    )
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME GDAL CONFIG_PATH lib/cmake/gdal)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(GLOB bin_files "${CURRENT_PACKAGES_DIR}/bin/*")
list(REMOVE_ITEM bin_files "${CURRENT_PACKAGES_DIR}/bin/gdal-config")
if(NOT bin_files)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/gdal/vcpkg-cmake-wrapper.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

return() # ^^^ cmake / legacy vvv

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/gdal
    REF v3.4.3
    SHA512 702bcb220abc7cf978e8f70a1b2835a20ce5abe405014b9690cab311c00837e57555bb371ff5e2655f9eed63cfd461d6cec5e654001b276dd79a6d2ec0c21f0b
    HEAD_REF master
    PATCHES
        0001-Fix-debug-crt-flags.patch
        0002-Fix-build.patch
        0004-Fix-cfitsio.patch
        0005-Fix-configure.patch
        0006-Fix-mingw-dllexport.patch
        0007-Control-tools.patch
        0008-Fix-absl-string_view.patch
        0009-atlbase.patch
        0010-symprefix.patch
)
# `vcpkg clean` stumbles over one subdir
file(REMOVE_RECURSE "${SOURCE_PATH}/autotest")

set(extra_exports "")
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if (VCPKG_CRT_LINKAGE STREQUAL "static")
        set(LINKAGE_FLAGS "/MT")
    else()
        set(LINKAGE_FLAGS "/MD")
    endif()

    set(NMAKE_OPTIONS
        "DATADIR=${CURRENT_PACKAGES_DIR}/share/gdal"
        "HTMLDIR=${CURRENT_PACKAGES_DIR}/share/gdal/html"
        "MSVC_VER=1900"
    )
    set(NMAKE_OPTIONS_REL
        "GDAL_HOME=${CURRENT_PACKAGES_DIR}"
        "CXX_CRT_FLAGS=${LINKAGE_FLAGS}"
    )
    set(NMAKE_OPTIONS_DBG
        "GDAL_HOME=${CURRENT_PACKAGES_DIR}/debug"
        "CXX_CRT_FLAGS=${LINKAGE_FLAGS}d"
        DEBUG=1
    )

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        list(APPEND NMAKE_OPTIONS "WIN64=YES")
    endif()

    if(VCPKG_TARGET_IS_UWP)
        list(APPEND NMAKE_OPTIONS "SYM_PREFIX=" "EXTRA_LINKER_FLAGS=/APPCONTAINER WindowsApp.lib")
    endif()

    if(NOT "aws-ec2-windows" IN_LIST FEATURES)
        list(APPEND NMAKE_OPTIONS "HAVE_ATLBASE_H=NO")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
        list(APPEND NMAKE_OPTIONS "SSEFLAGS=/DNO_SSSE" "AVXFLAGS=/DNO_AVX")
    endif()

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND NMAKE_OPTIONS "DLLBUILD=0")
    else()
        list(APPEND NMAKE_OPTIONS "DLLBUILD=1" "WITH_PDB=1")
    endif()

    include("${CMAKE_CURRENT_LIST_DIR}/dependency_win.cmake")
    find_dependency_win()

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
        OPTIONS
            ${NMAKE_OPTIONS}
        OPTIONS_RELEASE
            ${NMAKE_OPTIONS_REL}
        OPTIONS_DEBUG
            ${NMAKE_OPTIONS_DBG}
    )

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
        # vcpkg_copy_tools removes the bin directories for us so no need to remove again
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

    if ("poppler" IN_LIST FEATURES)
        add_config("--with-poppler=yes"  "Poppler support:           yes")
    elseif(DISABLE_SYSTEM_LIBRARIES)
        add_config("--with-poppler=no"   "Poppler support:           no")
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
            --with-pcre2=no
            --with-pdfium=no
            --with-podofo=no
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
        vcpkg_replace_string("${pc_file_debug}" "\${prefix}/../../include" "\${prefix}/../include")
        vcpkg_replace_string("${pc_file_debug}" "\${exec_prefix}/include" "\${prefix}/../include")
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gdal/bin/gdal-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gdal/debug/bin/gdal-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpl_config.h" "#define GDAL_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")

    if("libspatialite" IN_LIST FEATURES)
        list(APPEND extra_exports SPATIALITE)
        x_vcpkg_pkgconfig_get_modules(
            PREFIX SPATIALITE
            MODULES spatialite
            LIBS
        )
    endif()
endif()

string(COMPARE NOTEQUAL "${NMAKE_OPTIONS}" "" NMAKE_BUILD)
set(GDAL_EXTRA_LIBS_DEBUG "")
set(GDAL_EXTRA_LIBS_RELEASE "")
foreach(prefix IN LISTS extra_exports)
    string(REPLACE "${CURRENT_INSTALLED_DIR}/" "\${CMAKE_CURRENT_LIST_DIR}/../../" libs "${${prefix}_LIBS_DEBUG}")
    string(APPEND GDAL_EXTRA_LIBS_DEBUG " ${libs}")
    string(REPLACE "${CURRENT_INSTALLED_DIR}/" "\${CMAKE_CURRENT_LIST_DIR}/../../" libs "${${prefix}_LIBS_RELEASE}")
    string(APPEND GDAL_EXTRA_LIBS_RELEASE " ${libs}")
endforeach()
string(REPLACE "/lib/pkgconfig/../.." "" GDAL_EXTRA_LIBS_DEBUG "${GDAL_EXTRA_LIBS_DEBUG}")
string(REPLACE "/lib/pkgconfig/../.." "" GDAL_EXTRA_LIBS_RELEASE "${GDAL_EXTRA_LIBS_RELEASE}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/gdal/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
