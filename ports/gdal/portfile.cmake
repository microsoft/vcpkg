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
        gif             GDAL_USE_GIF
        hdf4            GDAL_USE_HDF4
        hdf4            GDAL_ENABLE_DRIVER_HDF4
        hdf5            GDAL_USE_HDF5
        core            GDAL_USE_ICONV # Always used if found.
        jpeg            GDAL_USE_JPEG
        core            GDAL_USE_JSONC #!
        libcsf          GDAL_USE_LIBCSF
         libcsf          GDAL_USE_LIBCSF_INTERNAL
        lerc            GDAL_USE_LERC
        liblzma         GDAL_USE_LIBLZMA
        libxml2         GDAL_USE_LIBXML2
        mysql-libmariadb  GDAL_USE_MYSQL 
        netcdf          GDAL_USE_NETCDF
        odbc            GDAL_USE_ODBC
        opencad         GDAL_USE_OPENCAD
        openjpeg        GDAL_USE_OPENJPEG #?
        pcre2           GDAL_USE_PCRE2
        png             GDAL_USE_PNG
        postgresql      GDAL_USE_POSTGRESQL
        core            GDAL_USE_QHULL
        rasterlite      GDAL_USE_RASTERLITE2
#         rasterlite      GDAL_ENABLE_DRIVER_RASTERLITE # HAVE_RASTERLITE
        shapelib        GDAL_USE_SHAPELIB
        libspatialite   GDAL_USE_SPATIALITE
        sqlite3         GDAL_USE_SQLITE3
        core            GDAL_USE_TIFF
        webp            GDAL_USE_WEBP
        xerces-c        GDAL_USE_XERCESC
        core            GDAL_USE_ZLIB
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
        -DGDAL_USE_INTERNAL_LIBS=OFF
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gdal)
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
