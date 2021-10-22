# test application for this port: https://github.com/mathisloge/mapnik-vcpkg-test

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapnik/mapnik
    REF 4695c42b51bc633e10b15c30ba580093ca0dda4f
    SHA512 c0e6c77b6c859ac03a2169d8f71ee2d68e6b76dd0295a0656f278f31ccf531b02f2a5bc5cce7e78177872fba2e5dda95dc00685d6157043fa3a246a072ab7075
    HEAD_REF master
    PATCHES
        cairo-find-fix.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "jpeg"                      USE_JPEG
        "png"                       USE_PNG
        "tiff"                      USE_TIFF
        "webp"                      USE_WEBP
        "libxml2"                   USE_LIBXML2
        "cairo"                     USE_CAIRO
        "proj"                      USE_PROJ
        "grid-renderer"             USE_GRID_RENDERER
        "svg-renderer"              USE_SVG_RENDERER
        "input-csv"                 USE_PLUGIN_INPUT_CSV
        "input-gdal"                USE_PLUGIN_INPUT_GDAL
        "input-geobuf"              USE_PLUGIN_INPUT_GEOBUF
        "input-geojson"             USE_PLUGIN_INPUT_GEOJSON
        "input-ogr"                 USE_PLUGIN_INPUT_OGR
        "input-pgraster"            USE_PLUGIN_INPUT_PGRASTER
        "input-postgis"             USE_PLUGIN_INPUT_POSTGIS
        "input-raster"              USE_PLUGIN_INPUT_RASTER
        "input-shape"               USE_PLUGIN_INPUT_SHAPE
        "input-sqlite"              USE_PLUGIN_INPUT_SQLITE
        "input-topojson"            USE_PLUGIN_INPUT_TOPOJSON
        "viewer"                    BUILD_DEMO_VIEWER
        "utility-geometry-to-wkb"   BUILD_UTILITY_GEOMETRY_TO_WKB
        "utility-mapnik-index"      BUILD_UTILITY_MAPNIK_INDEX
        "utility-mapnik-render"     BUILD_UTILITY_MAPNIK_RENDER
        "utility-ogrindex"          BUILD_UTILITY_OGRINDEX
        "utility-pgsql2sqlite"      BUILD_UTILITY_PGSQL2SQLITE
        "utility-shapeindex"        BUILD_UTILITY_SHAPEINDEX
        "utility-svg2png"           BUILD_UTILITY_SVG2PNG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS   
        ${FEATURE_OPTIONS}
        -DCOPY_LIBRARIES_FOR_EXECUTABLES=OFF
        -DCOPY_FONTS_AND_PLUGINS_FOR_EXECUTABLES=OFF
        -DINSTALL_DEPENDENCIES=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCHMARK=OFF
        -DBUILD_DEMO_CPP=OFF
        -DUSE_EXTERNAL_MAPBOX_GEOMETRY=ON
        -DUSE_EXTERNAL_MAPBOX_POLYLABEL=ON
        -DUSE_EXTERNAL_MAPBOX_PROTOZERO=ON
        -DUSE_EXTERNAL_MAPBOX_VARIANT=ON
        -DMAPNIK_CMAKE_DIR=share/mapnik/cmake
        -DFONTS_INSTALL_DIR=share/mapnik/fonts
        -DMAPNIK_PKGCONF_DIR=lib/pkgconfig
)

vcpkg_cmake_install()
# copy plugins into tool path, if any plugin is installed
if(IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/plugins")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/plugins" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()
vcpkg_copy_pdbs()

set(_tool_names "")
if("viewer" IN_LIST FEATURES)
    # copy the ini file to reference the plugins correctly
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/viewer.ini" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    list(APPEND _tool_names mapnik-viewer)
endif()

if("utility-geometry-to-wkb" IN_LIST FEATURES)
    list(APPEND _tool_names geometry_to_wkb)
endif()

if("utility-mapnik-index" IN_LIST FEATURES)
    list(APPEND _tool_names mapnik-index)
endif()
if("utility-mapnik-render" IN_LIST FEATURES)
    list(APPEND _tool_names mapnik-render)
endif()
if("utility-ogrindex" IN_LIST FEATURES)
    # build is currently not supported
    # vcpkg_copy_tools(TOOL_NAMES ogrindex AUTO_CLEAN)
endif()
if("utility-pgsql2sqlite" IN_LIST FEATURES)
    list(APPEND _tool_names pgsql2sqlite)
endif()
if("utility-shapeindex" IN_LIST FEATURES)
    list(APPEND _tool_names shapeindex)
endif()
if("utility-svg2png" IN_LIST FEATURES)
    list(APPEND _tool_names svg2png)
endif()
if(_tool_names)
    vcpkg_copy_tools(TOOL_NAMES ${_tool_names} AUTO_CLEAN)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH share/mapnik/cmake)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/mapnik/mapnikPlugins-debug.cmake" "set(MAPNIK_PLUGINS_DIR_DEBUG \"\${PACKAGE_PREFIX_DIR}/debug/bin/mapnik/input\" CACHE STRING \"\")")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/fonts/unifont_license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME fonts_copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
