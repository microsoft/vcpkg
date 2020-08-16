find_program(GIT git)

set(GIT_URL "https://github.com/am2222/mapnik-windows.git")
set(GIT_REV "5ec01cfa138fd3402e5cbf7d19f6fdb26ee63946")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})


if(NOT EXISTS "${SOURCE_PATH}/.git")
	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recurse-submodules ${GIT_URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)

	message(STATUS "Checkout revision ${GIT_REV}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${GIT_REV}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)
endif()


vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path(${PYTHON2_DIR})

set(BOOST_ROOT ${CURRENT_INSTALLED_DIR})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(MAPNIK_STATIC_LIB OFF)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(MAPNIK_STATIC_LIB ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cairo   WITH_CAIRO
    demo  WITH_DEMO
    input_csv WITH_INPUT_CSV
    input_gdal WITH_INPUT_GDAL
    input_geobuf  WITH_INPUT_GEOBUF
    input_geojson   WITH_INPUT_GEOJSON
    input_ogr WITH_INPUT_OGR
    input_pgraster  WITH_INPUT_PGRASTER
    input_postgis  WITH_INPUT_POSTGIS
    input_raster  WITH_INPUT_RASTER
    input_shape WITH_INPUT_SHAPE
    input_sqlite WITH_INPUT_SQLITE
    input_topojson  WITH_INPUT_TOPOJSON
    proj4 WITH_PROJ4
    utils WITH_UTILS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS   
        ${FEATURE_OPTIONS}
        -DMAPNIK_STATIC_LIB=${MAPNIK_STATIC_LIB}
        -DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
        -DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/${PORT} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

if ("utils" IN_LIST FEATURES)
    vcpkg_copy_tools(
      TOOL_NAMES mapnik-demo mapnik-render shapeindex
      AUTO_CLEAN
    )
    
    file(COPY ${SOURCE_PATH}/demo/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik/demo)
    file(COPY ${SOURCE_PATH}/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/plugins DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)

    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mapnik-demo ${CURRENT_PACKAGES_DIR}/debug/bin/mapnik-render ${CURRENT_PACKAGES_DIR}/debug/bin/shapeindex)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/fonts/unifont_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME fonts_copyright)
