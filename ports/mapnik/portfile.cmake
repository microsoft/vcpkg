vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathisloge/mapnik
    REF 7897bb5c83e0394325fcd438f6bb9d7c149d7c5e
    SHA512 ab8c6e0a35ab55b71a4ec4effa12d8a80ae46d04b4d889d8885e295bbe4ee210bfa3ee8048060750d96dd094fbfaa9004315699a87ba4919bbd8f21bca228b85
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    jpeg              USE_JPEG
    png               USE_PNG
    tiff              USE_TIFF
    webp              USE_WEBP
    libxml2           USE_LIBXML2
    cairo             USE_CAIRO
    proj              USE_PROJ
    "grid-renderer"   USE_GRID_RENDERER
    "svg-renderer"    USE_SVG_RENDERER
    "input-csv"       USE_PLUGIN_INPUT_CSV
    "input-gdal"      USE_PLUGIN_INPUT_GDAL
    "input-geobuf"    USE_PLUGIN_INPUT_GEOBUF
    "input-geojson"   USE_PLUGIN_INPUT_GEOJSON
    "input-ogr"       USE_PLUGIN_INPUT_OGR
    "input-pgraster"  USE_PLUGIN_INPUT_PGRASTER
    "input-postgis"   USE_PLUGIN_INPUT_POSTGIS
    "input-raster"    USE_PLUGIN_INPUT_RASTER
    "input-shape"     USE_PLUGIN_INPUT_SHAPE
    "input-sqlite"    USE_PLUGIN_INPUT_SQLITE
    "input-topojson"  USE_PLUGIN_INPUT_TOPOJSON
    viewer            BUILD_DEMO_VIEWER
    demo              BUILD_DEMO_CPP
    "utility-geometry-to-wkb" BUILD_UTILITY_GEOMETRY_TO_WKB
    "utility-mapnik-index" BUILD_UTILITY_MAPNIK_INDEX
    "utility-mapnik-render" BUILD_UTILITY_MAPNIK_RENDER
    "utility-ogrindex" BUILD_UTILITY_OGRINDEX
    "utility-pgsql2sqlite" BUILD_UTILITY_PGSQL2SQLITE
    "utility-shapeindex" BUILD_UTILITY_SHAPEINDEX
    "utility-svg2png" BUILD_UTILITY_SVG2PNG
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS   
        ${FEATURE_OPTIONS}
        -DCOPY_LIBRARIES_FOR_EXECUTABLES=OFF
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_TEST=OFF
        -DUSE_EXTERNAL_MAPBOX_GEOMETRY=ON
        -DUSE_EXTERNAL_MAPBOX_POLYLABEL=ON
        -DUSE_EXTERNAL_MAPBOX_PROTOZERO=ON
        -DUSE_EXTERNAL_MAPBOX_VARIANT=ON
        -DINSTALL_CMAKE_DIR=share/mapnik/cmake
)

vcpkg_install_cmake()

# copy plugins into tool path, if any plugin is installed
if(IS_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin/plugins)
  file(COPY ${CURRENT_PACKAGES_DIR}/bin/plugins DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()
vcpkg_copy_pdbs()

if("demo" IN_LIST FEATURES)
  file(COPY ${SOURCE_PATH}/demo/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/demo)
  vcpkg_copy_tools(TOOL_NAMES mapnik-demo AUTO_CLEAN)
endif()

if("viewer" IN_LIST FEATURES)
  # copy the ini file to reference the plugins correctly
  file(COPY ${CURRENT_PACKAGES_DIR}/bin/viewer.ini DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  vcpkg_copy_tools(TOOL_NAMES mapnik-viewer AUTO_CLEAN)
endif()

if("utility-geometry-to-wkb" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES geometry_to_wkb AUTO_CLEAN)
endif()

if("utility-mapnik-index" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES mapnik-index AUTO_CLEAN)
endif()
if("utility-mapnik-render" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES mapnik-render AUTO_CLEAN)
endif()
if("utility-ogrindex" IN_LIST FEATURES)
  # build is currently not supported
  # vcpkg_copy_tools(TOOL_NAMES ogrindex AUTO_CLEAN)
endif()
if("utility-pgsql2sqlite" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES pgsql2sqlite AUTO_CLEAN)
endif()
if("utility-shapeindex" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES shapeindex AUTO_CLEAN)
endif()
if("utility-svg2png" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES svg2png AUTO_CLEAN)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/mapnik/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/fonts/unifont_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME fonts_copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
