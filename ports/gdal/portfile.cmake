vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/gdal
    REF "v${VERSION}"
    SHA512 db23c751aa1bfc9f9f80c4dc900e86fb19579251d3577ef5bd06f9ddf76ba8c74aa404b5477ced5649d011e2111ca8df38d5acc87de6723f7e50f3bb22c9ee8f
    HEAD_REF master
    PATCHES
        find-link-libraries.patch
        fix-gdal-target-interfaces.patch
        libkml.patch
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
        lerc             GDAL_USE_LERC
        libkml           GDAL_USE_LIBKML
        lzma             GDAL_USE_LIBLZMA
        libxml2          GDAL_USE_LIBXML2
        mysql-libmariadb GDAL_USE_MYSQL 
        netcdf           GDAL_USE_NETCDF
        odbc             GDAL_USE_ODBC
        openjpeg         GDAL_USE_OPENJPEG
        openssl          GDAL_USE_OPENSSL
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
if(VCPKG_TARGET_IS_ANDROID AND ANRDOID_PLATFORM VERSION_LESS 24 AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm"))
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
        -DCMAKE_DISABLE_FIND_PACKAGE_Arrow=ON
        -DGDAL_USE_INTERNAL_LIBS=OFF
        -DGDAL_USE_EXTERNAL_LIBS=OFF
        -DGDAL_BUILD_OPTIONAL_DRIVERS=ON
        -DOGR_BUILD_OPTIONAL_DRIVERS=ON
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
