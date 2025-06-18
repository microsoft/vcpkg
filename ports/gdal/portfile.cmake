vcpkg_download_distfile(
    arm_neon_diff
    URLS "https://github.com/OSGeo/gdal/pull/12343/commits/444dd0c302b7c12e87ea8497038eee76586ee920.diff?full_index=1"
    FILENAME "OSGeo-gdal-v3.11.0-444dd0c.diff"
    SHA512 c9f725c1ea7707eaeb2edb36fcf682aafbd38170718c89b949567b7271e17b98c24b2e1b4e0d47a760a9213ba18b9abc9c2046b7e4fa7fef4538f6fece7f22e1
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/gdal
    REF "v${VERSION}"
    SHA512 7a31cd0466a50b2e118b49eb2eca2b945377c2f9cb99196f98259904ff5f71278caef568582e510f500881621f58da095e7007116ee5a51e8693f0e15cb3ce19
    HEAD_REF master
    PATCHES
        find-link-libraries.patch
        fix-gdal-target-interfaces.patch
        libkml.patch
        sqlite3.diff
        target-is-valid.patch
        ${arm_neon_diff}
)
# `vcpkg clean` stumbles over one subdir
file(REMOVE_RECURSE "${SOURCE_PATH}/autotest")

# Avoid abseil, no matter if vcpkg or system
vcpkg_replace_string("${SOURCE_PATH}/ogr/ogrsf_frmts/flatgeobuf/flatbuffers/base.h" [[__has_include("absl/strings/string_view.h")]] "(0)")

# Cf. cmake/helpers/CheckDependentLibraries.cmake
# The default for all `GDAL_USE_<PKG>` dependencies is `OFF`.
# Here, we explicitly control dependencies provided via vpcpkg.
# "core" is used for a dependency which must be enabled to avoid vendored lib.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arrow            GDAL_USE_ARROW
        archive          GDAL_USE_ARCHIVE
        cfitsio          GDAL_USE_CFITSIO
        curl             GDAL_USE_CURL
        expat            GDAL_USE_EXPAT
        freexl           GDAL_USE_FREEXL
        geos             GDAL_USE_GEOS
        core             GDAL_USE_GEOTIFF
        gif              GDAL_USE_GIF
        hdf5             GDAL_USE_HDF5
        iconv            GDAL_USE_ICONV
        jpeg             GDAL_USE_JPEG
        core             GDAL_USE_JSONC
        kea              GDAL_USE_KEA
        lerc             GDAL_USE_LERC
        libkml           GDAL_USE_LIBKML
        lzma             GDAL_USE_LIBLZMA
        libxml2          GDAL_USE_LIBXML2
        mysql-libmariadb GDAL_USE_MYSQL 
        netcdf           GDAL_USE_NETCDF
        odbc             GDAL_USE_ODBC
        openjpeg         GDAL_USE_OPENJPEG
        openssl          GDAL_USE_OPENSSL
        parquet          GDAL_USE_PARQUET
        pcre2            GDAL_USE_PCRE2
        png              GDAL_USE_PNG
        poppler          GDAL_USE_POPPLER
        postgresql       GDAL_USE_POSTGRESQL
        qhull            GDAL_USE_QHULL
        #core             GDAL_USE_SHAPELIB  # https://github.com/OSGeo/gdal/issues/5711, https://github.com/microsoft/vcpkg/issues/16041
        core             GDAL_USE_SHAPELIB_INTERNAL
        libspatialite    GDAL_USE_SPATIALITE
        sqlite3          GDAL_USE_SQLITE3
        core             GDAL_USE_TIFF
        webp             GDAL_USE_WEBP
        core             GDAL_USE_ZLIB
        zstd             GDAL_USE_ZSTD
        tools            BUILD_APPS
    INVERTED_FEATURES
        libspatialite    CMAKE_DISABLE_FIND_PACKAGE_SPATIALITE
)
if(GDAL_USE_ICONV AND VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS -D_ICONV_SECOND_ARGUMENT_IS_NOT_CONST=ON)
endif()

# Compatibility with older Android versions https://github.com/OSGeo/gdal/pull/5941
if(VCPKG_TARGET_IS_ANDROID AND ANDROID_PLATFORM VERSION_LESS 24 AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm"))
    list(APPEND FEATURE_OPTIONS -DBUILD_WITHOUT_64BIT_OFFSET=ON)
endif()

string(REPLACE "dynamic" "" qhull_target "Qhull::qhull${VCPKG_LIBRARY_LINKAGE}_r")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET} # for host pkgconf in PATH
        ${FEATURE_OPTIONS}
        -DBUILD_DOCS=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_CSharp=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Java=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DGDAL_USE_INTERNAL_LIBS=OFF
        -DGDAL_USE_EXTERNAL_LIBS=OFF
        -DGDAL_BUILD_OPTIONAL_DRIVERS=ON
        -DOGR_BUILD_OPTIONAL_DRIVERS=ON
        -DFIND_PACKAGE2_KEA_ENABLED=OFF
        -DGDAL_CHECK_PACKAGE_MySQL_NAMES=unofficial-libmariadb
        -DGDAL_CHECK_PACKAGE_MySQL_TARGETS=unofficial::libmariadb
        -DMYSQL_LIBRARIES=unofficial::libmariadb
        -DGDAL_CHECK_PACKAGE_NetCDF_NAMES=netCDF
        -DGDAL_CHECK_PACKAGE_NetCDF_TARGETS=netCDF::netcdf
        -DGDAL_CHECK_PACKAGE_QHULL_NAMES=Qhull
        "-DGDAL_CHECK_PACKAGE_QHULL_TARGETS=${qhull_target}"
        "-DQHULL_LIBRARY=${qhull_target}"
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
    OPTIONS_DEBUG
        -DBUILD_APPS=OFF
    MAYBE_UNUSED_VARIABLES
        QHULL_LIBRARY
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gdal)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/gdal/GDALConfig.cmake"
    "include(CMakeFindDependencyMacro)"
    "include(CMakeFindDependencyMacro)
# gdal needs a pkg-config tool. A host dependency provides pkgconf.
get_filename_component(vcpkg_host_prefix \"\${CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}\" ABSOLUTE)
list(APPEND CMAKE_PROGRAM_PATH \"\${vcpkg_host_prefix}/tools/pkgconf\")"
)

if (BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES
            gdal
            gdal_contour
            gdal_create
            gdal_footprint
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
            sozip
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/gdal-config" "${CURRENT_PACKAGES_DIR}/debug/bin/gdal-config")

file(GLOB bin_files "${CURRENT_PACKAGES_DIR}/bin/*")
if(NOT bin_files)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpl_config.h" "#define GDAL_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
