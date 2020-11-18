vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapnik/mapnik
    REF c6fc956a779123e3735c16ba28aa85922b924cac
    SHA512 a30d8d82e5f0f9f344036858d248ee88872b6f9314e59206e7f127449fb7b9e6af62f624a8e81e1db79723c0dc7324ca8ec970d15646b253a1a28992160c7a3a
    HEAD_REF master
    PATCHES
      fix-config.patch
      fix-box2d.patch
      fix-constructor-inheritance.patch
      fix-csv.patch
      fix-geojson-plugin.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/ DESTINATION ${SOURCE_PATH})

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path(${PYTHON2_DIR})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(MAPNIK_STATIC_LIB OFF)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(MAPNIK_STATIC_LIB ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cairo             WITH_CAIRO
    demo              WITH_DEMO
    viewer            WITH_VIEWER
    "input-csv"       WITH_INPUT_CSV
    "input-gdal"      WITH_INPUT_GDAL
    "input-geobuf"    WITH_INPUT_GEOBUF
    "input-geojson"   WITH_INPUT_GEOJSON
    "input-ogr"       WITH_INPUT_OGR
    "input-pgraster"  WITH_INPUT_PGRASTER
    "input-postgis"   WITH_INPUT_POSTGIS
    "input-raster"    WITH_INPUT_RASTER
    "input-shape"     WITH_INPUT_SHAPE
    "input-sqlite"    WITH_INPUT_SQLITE
    "input-topojson"  WITH_INPUT_TOPOJSON
    proj4             WITH_PROJ4
    utils             WITH_UTILS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS   
        ${FEATURE_OPTIONS}
        -DMAPNIK_STATIC_LIB=${MAPNIK_STATIC_LIB}
        -DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
        -DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/${PORT} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

if("demo" IN_LIST FEATURES)
  file(COPY ${SOURCE_PATH}/demo/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik/demo)
  vcpkg_copy_tools(TOOL_NAMES mapnik-demo AUTO_CLEAN)
endif()

if("viewer" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES mapnik-viewer AUTO_CLEAN)
endif()

if ("utils" IN_LIST FEATURES)
  vcpkg_copy_tools(
    TOOL_NAMES mapnik-render shapeindex
    AUTO_CLEAN
  )
  file(COPY ${SOURCE_PATH}/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
  #file(COPY ${CURRENT_PACKAGES_DIR}/bin/plugins DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/fonts/unifont_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME fonts_copyright)
