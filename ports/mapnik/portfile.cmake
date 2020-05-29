set(MAPNIK_VERSION 3.0.22)
include(vcpkg_common_functions)
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
set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")

set(BOOST_ROOT ${CURRENT_INSTALLED_DIR})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(MAPNIK_STATIC_LIB OFF)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(MAPNIK_STATIC_LIB ON)
endif()



if ("WITH_CAIRO" IN_LIST FEATURES)
  set(CMAKE_WITH_CAIRO ON)
else()
  set(CMAKE_WITH_CAIRO OFF)
endif()

if ("WITH_DEMO" IN_LIST FEATURES)
  set(CMAKE_DEMO ON)
else()
  set(CMAKE_DEMO OFF)
endif()

if ("WITH_GRID" IN_LIST FEATURES)
  set(CMAKE_GRID ON)
else()
  set(CMAKE_GRID OFF)
endif()


if ("WITH_INPUT_CSV" IN_LIST FEATURES)
  set(CMAKE_INPUT_CSV ON)
else()
  set(CMAKE_INPUT_CSV OFF)
endif()

if ("WITH_INPUT_GDAL" IN_LIST FEATURES)
  set(CMAKE_INPUT_GDAL ON)
else()
  set(CMAKE_INPUT_GDAL OFF)
endif()


if ("WITH_INPUT_GEOBUF" IN_LIST FEATURES)
  set(CMAKE_GEOBUF ON)
else()
  set(CMAKE_GEOBUF OFF)
endif()


if ("WITH_INPUT_GEOJSON" IN_LIST FEATURES)
  set(CMAKE_GEOJSON ON)
else()
  set(CMAKE_GEOJSON OFF)
endif()

if ("WITH_INPUT_OGR" IN_LIST FEATURES)
  set(CMAKE_OGR ON)
else()
  set(CMAKE_OGR OFF)
endif()


if ("WITH_INPUT_PGRASTER" IN_LIST FEATURES)
  set(CMAKE_PGRASTER ON)
else()
  set(CMAKE_PGRASTER OFF)
endif()


if ("WITH_INPUT_POSTGIS" IN_LIST FEATURES)
  set(CMAKE_POSTGIS ON)
else()
  set(CMAKE_POSTGIS OFF)
endif()


if ("WITH_INPUT_RASTER" IN_LIST FEATURES)
  set(CMAKE_RASTER ON)
else()
  set(CMAKE_RASTER OFF)
endif()



if ("WITH_INPUT_SHAPE" IN_LIST FEATURES)
  set(CMAKE_SHAPE ON)
else()
  set(CMAKE_SHAPE OFF)
endif()



if ("WITH_INPUT_SQLITE" IN_LIST FEATURES)
  set(CMAKE_SQLITE ON)
else()
  set(CMAKE_SQLITE OFF)
endif()

if ("WITH_INPUT_TOPOJSON" IN_LIST FEATURES)
  set(CMAKE_TOPOJSON ON)
else()
  set(CMAKE_TOPOJSON OFF)
endif()

if ("WITH_PROJ4" IN_LIST FEATURES)
  set(CMAKE_PROJ4 ON)
else()
  set(CMAKE_PROJ4 OFF)
endif()


if ("WITH_UTILS" IN_LIST FEATURES)
  set(CMAKE_UTILS ON)
else()
  set(CMAKE_UTILS OFF)
endif()

if ("WITH_VIEWER" IN_LIST FEATURES)
  set(CMAKE_VIEWER ON)
else()
  set(CMAKE_VIEWER OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mapnik
 #    PREFER_NINJA # Disable this option if project cannot be built with Ninja
#    NO_CHARSET_FLAG # automatic templates
	OPTIONS   
		-DWITH_CAIRO={$CMAKE_WITH_CAIRO}
		-DWITH_DEMO={$CMAKE_DEMO}
		#-DWITH_GRID={$CMAKE_}
		-DWITH_INPUT_CSV={$CMAKE_CSV}
		-DWITH_INPUT_GDAL={$CMAKE_GDAL}
		-DWITH_INPUT_GEOBUF={$CMAKE_GEOBUF}
		-DWITH_INPUT_GEOJSON={$CMAKE_GEOJSON=}
		-DWITH_INPUT_OGR={$CMAKE_OGR}
		-DWITH_INPUT_PGRASTER={$CMAKE_PGRASTER}
		-DWITH_INPUT_POSTGIS={$CMAKE_POSTGIS}
		-DWITH_INPUT_RASTER={$CMAKE_RASTER}
		-DWITH_INPUT_SHAPE={$CMAKE_SHAPE}
		-DWITH_INPUT_SQLITE={$CMAKE_SQLITE}
		-DWITH_INPUT_TOPOJSON={$CMAKE_TOPOJSON}
		-DWITH_PROJ4={$CMAKE_PROJ4}
		-DWITH_UTILS={$CMAKE_UTILS}
		#-DWITH_VIEWER={$CMAKE_VIEWER}
    	-DMAPNIK_STATIC_LIB=${MAPNIK_STATIC_LIB}
    	-DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
    	-DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()



file(COPY ${SOURCE_PATH}/include/mapnik DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
    file(REMOVE ${EXES})
    
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/mapnik)
    file(COPY ${SOURCE_PATH}/demo/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik/demo)
    file(COPY ${SOURCE_PATH}/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/plugins DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
endif()

file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(DEBUG_EXES)
    file(REMOVE ${EXES})
endif()




#file(REMOVE_RECURSE  "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapnik RENAME copyright)
file(INSTALL ${SOURCE_PATH}/fonts/unifont_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapnik RENAME fonts_copyright)