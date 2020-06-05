find_program(GIT git)
set(GIT_URL "https://github.com/am2222/mapnik-windows.git")
set(GIT_REV "fdba45cd95b66576e47de2e56d30196bfc9de99d")

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
message(STATUS "Adding worktree done")


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
  # Keyword FEATURES is optional if INVERTED_FEATURES are not used
    CAIRO   WITH_CAIRO
    DEMO  WITH_DEMO
    INPUT_CSV WITH_INPUT_CSV
    INPUT_GDAL WITH_INPUT_GDAL
    INPUT_GEOBUF  WITH_INPUT_GEOBUF
    INPUT_GEOJSON   WITH_INPUT_GEOJSON
    INPUT_OGR WITH_INPUT_OGR
    INPUT_PGRASTER  WITH_INPUT_PGRASTER
    INPUT_POSTGIS  WITH_INPUT_POSTGIS
    INPUT_RASTER  WITH_INPUT_RASTER
    INPUT_SHAPE WITH_INPUT_SHAPE
    INPUT_SQLITE WITH_INPUT_SQLITE
    INPUT_TOPOJSON  WITH_INPUT_TOPOJSON
    PROJ4 WITH_PROJ4
    UTILS WITH_UTILS

)


vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT}
 #    PREFER_NINJA # Disable this option if project cannot be built with Ninja
#    NO_CHARSET_FLAG # automatic templates
  OPTIONS   
      ${FEATURE_OPTIONS}
    	-DMAPNIK_STATIC_LIB=${MAPNIK_STATIC_LIB}
    	-DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
    	-DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()



file(COPY ${SOURCE_PATH}/include/${PORT} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

if ("UTILS" IN_LIST FEATURES)
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