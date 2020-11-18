cmake_minimum_required(VERSION 3.13.4)
project(mapnik)

set(MAPNIK_MAJOR_VERSION 3)
set(MAPNIK_MINOR_VERSION 0)
set(MAPNIK_PATCH_VERSION 23)
set(MAPNIK_VERSION ${MAPNIK_MAJOR_VERSION}.${MAPNIK_MINOR_VERSION}.${MAPNIK_PATCH_VERSION})

include(CMakeDependentOption)


option(MAPNIK_STATIC_LIB   "Build a static library" ON)

option(WITH_DEMO   "Build demo" ON)
option(WITH_VIEWER "Build viewer"  OFF)


option(WITH_INPUTS "Build input plugins" ON)

CMAKE_DEPENDENT_OPTION(WITH_INPUT_CSV       "Build the csv input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_GDAL      "Build the gdal input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_GEOBUF    "Build the geobuf input plugin" OFF "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_GEOJSON   "Build the geojson input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_OGR       "Build the ogr input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_PGRASTER  "Build the pgraster input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_POSTGIS   "Build the postgis input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_RASTER    "Build the raster input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_SHAPE     "Build the shape input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_SQLITE    "Build the sqlite input plugin" ON "WITH_INPUTS" ON)
CMAKE_DEPENDENT_OPTION(WITH_INPUT_TOPOJSON  "Build the topojson input plugin" ON "WITH_INPUTS" ON)

option(WITH_UTILS  "Build the utilities" ON )

option(WITH_GRID "Use the grid renderer" OFF)
option(WITH_CAIRO "Use cairo" ON)
option(WITH_PROJ4 "Use proj4" ON)

if(MSVC)
  # Force to always compile with W4
  if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W1" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W1")
  endif()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  /wd\"4068\" /wd\"4661\" /wd\"4503\" ")
  add_compile_options(/MP)
  add_compile_options(-bigobj) #added by @am2222
  add_compile_definitions(ACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1) #added by @am2222 for proj4 compile


endif()

find_package(Boost REQUIRED
             COMPONENTS filesystem system regex program_options)

find_package(freetype CONFIG REQUIRED)

find_package(harfbuzz CONFIG REQUIRED)
find_package(ICU REQUIRED COMPONENTS uc)

find_package(PNG     REQUIRED)
find_package(JPEG    REQUIRED)
find_package(TIFF    REQUIRED)
find_package(WebP CONFIG REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(ZLIB    REQUIRED)

set (MAPNIK_DEFS 
    -DHAVE_PNG
    -DHAVE_JPEG
    -DHAVE_TIFF
    -DHAVE_WEBP)

# AGG
include(files.cmake)

if (WITH_CAIRO)
    find_package(unofficial-cairo CONFIG REQUIRED)

    set(MAPNIK_SOURCES ${MAPNIK_SOURCES}
        src/cairo/process_markers_symbolizer.cpp
        src/cairo/process_group_symbolizer.cpp
        
        src/cairo/cairo_context.cpp
        src/cairo/cairo_render_vector.cpp
        src/cairo/cairo_renderer.cpp
        src/cairo/process_building_symbolizer.cpp
        src/cairo/process_debug_symbolizer.cpp
        src/cairo/process_line_pattern_symbolizer.cpp
        src/cairo/process_line_symbolizer.cpp
        src/cairo/process_point_symbolizer.cpp
        src/cairo/process_polygon_pattern_symbolizer.cpp
        src/cairo/process_polygon_symbolizer.cpp
        src/cairo/process_raster_symbolizer.cpp
        src/cairo/process_text_symbolizer.cpp)
        
    set(MAPNIK_DEFS ${MAPNIK_DEFS} -DHAVE_CAIRO)

    set(OPTIONAL_LIBRARIES ${OPTIONAL_LIBRARIES} unofficial::cairo::cairo)
endif()
message(STATUS "Cairo renderer " ${WITH_CAIRO})

if (WITH_PROJ4)
    find_package(PROJ4 CONFIG REQUIRED)
    set(OPTIONAL_LIBRARIES ${OPTIONAL_LIBRARIES} proj)
    set(MAPNIK_DEFS ${MAPNIK_DEFS} -DMAPNIK_USE_PROJ4)
endif()

if (WITH_GRID)
    set(MAPNIK_SOURCES ${MAPNIK_SOURCES}
        src/grid/grid.cpp
        src/grid/grid_renderer.cpp
        src/grid/process_building_symbolizer.cpp
        src/grid/process_line_pattern_symbolizer.cpp
        src/grid/process_line_symbolizer.cpp
        src/grid/process_point_symbolizer.cpp
        src/grid/process_polygon_pattern_symbolizer.cpp
        src/grid/process_polygon_symbolizer.cpp
        src/grid/process_raster_symbolizer.cpp
        src/grid/process_shield_symbolizer.cpp
        src/grid/process_text_symbolizer.cpp)
    set(MAPNIK_DEFS ${MAPNIK_DEFS} -DGRID_RENDERER)
endif()
message(STATUS "Grid renderer: " ${WITH_GRID})
    
set(MAPNIK_SOURCES ${MAPNIK_SOURCES}
    src/svg/output/svg_output_grammars.cpp
    src/svg/output/svg_renderer.cpp
    src/svg/output/svg_generator.cpp
    src/svg/output/svg_output_attributes.cpp
    src/svg/output/process_symbolizers.cpp
    src/svg/output/process_line_symbolizer.cpp
    src/svg/output/process_polygon_symbolizer.cpp)
set(MAPNIK_DEFS ${MAPNIK_DEFS} -DSVG_RENDERER)

    
set(MAPNIK_SOURCES ${MAPNIK_SOURCES}
    src/jpeg_reader.cpp
    src/libxml2_loader.cpp
    src/png_reader.cpp
    src/tiff_reader.cpp
    src/webp_reader.cpp
)
    
#set(MAPNIK_SOURCES ${MAPNIK_SOURCES} src/rapidxml_loader.cpp)

#vcpkg only supports icu on windows
if(WIN32)
    set(MAPNIK_DEFS ${MAPNIK_DEFS} -DHAVE_LIBXML2 -DBOOST_REGEX_HAS_ICU)
endif()

find_path(MAPBOX_POLYLABEL_INCLUDE_DIRS "mapbox/polylabel.hpp")
find_path(MAPBOX_GEOMETRY_INCLUDE_DIRS "mapbox/feature.hpp")
find_path(MAPBOX_VARIANT_INCLUDE_DIRS "mapbox/optional.hpp")


set(MAPNIK_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/include)

set(mapnik_include_paths
    ${PROJECT_SOURCE_DIR}/deps
    ${PROJECT_SOURCE_DIR}/deps/agg/include)

add_library(mapnik ${MAPNIK_SOURCES} ${MAPNIK_AGG_SOURCES} ${AGG_SOURCES})
if (MAPNIK_STATIC_LIB)
    message(STATUS "Building static library")
    set_target_properties(mapnik PROPERTIES DEFINE_SYMBOL MAPNIK_STATICLIB)
    set(MAPNIK_LIB_DEFINITION -DMAPNIK_STATICLIB)
else ()
    message(STATUS "Building shared library")
    set_target_properties(mapnik PROPERTIES DEFINE_SYMBOL MAPNIK_EXPORTS)
    set(MAPNIK_LIB_DEFINITION -DMAPNIK_EXPORTS)
endif ()


target_compile_definitions(mapnik PUBLIC ${MAPNIK_DEFS})
target_include_directories(mapnik PUBLIC  
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>  
    $<INSTALL_INTERFACE:include>
)
target_include_directories(mapnik PRIVATE 
    ${mapnik_include_paths}
    ${JPEG_INCLUDE_DIR}
    ${LIBXML2_INCLUDE_DIR}
    ${MAPBOX_POLYLABEL_INCLUDE_DIRS} 
    ${MAPBOX_GEOMETRY_INCLUDE_DIRS}
    ${MAPBOX_VARIANT_INCLUDE_DIRS}
)
target_link_libraries(mapnik PUBLIC
    Boost::boost Boost::filesystem Boost::system Boost::regex Boost::program_options Boost::system
    WebP::webp WebP::webpdemux WebP::libwebpmux WebP::webpdecoder
    freetype
    ICU::uc
    PNG::PNG
    TIFF::TIFF
    ZLIB::ZLIB
    harfbuzz::harfbuzz
    JPEG::JPEG
    ${LIBXML2_LIBRARIES}
    ${OPTIONAL_LIBRARIES}
)


install(TARGETS mapnik 
    EXPORT MapnikTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

add_subdirectory(src/json)
add_subdirectory(src/wkt)


install(EXPORT MapnikTargets
        FILE MapnikTargets.cmake
        NAMESPACE mapnik::
        DESTINATION lib/cmake/mapnik
)


# ideally we should also generate mapnik-config

if (WITH_INPUT_CSV)
    add_subdirectory(plugins/input/csv)
endif()

if (WITH_INPUT_GDAL)
    find_package(GDAL REQUIRED)
    add_subdirectory(plugins/input/gdal)
endif()

if (WITH_INPUT_GEOBUF)
    add_subdirectory(plugins/input/geobuf)
endif()

if (WITH_INPUT_GEOJSON)
    add_subdirectory(plugins/input/geojson)
endif()

if (WITH_INPUT_OGR)
    add_subdirectory(plugins/input/ogr)
endif()

if (WITH_INPUT_PGRASTER)
    find_package(PostgreSQL REQUIRED)
    add_subdirectory(plugins/input/pgraster)
endif()

if (WITH_INPUT_POSTGIS)
    find_package(PostgreSQL REQUIRED)
    add_subdirectory(plugins/input/postgis)
endif()

if (WITH_INPUT_RASTER)
    add_subdirectory(plugins/input/raster)
endif()

if (WITH_INPUT_SHAPE)
    add_subdirectory(plugins/input/shape)
endif()

if (WITH_INPUT_SQLITE)
    find_package(SQLite3 REQUIRED)
    add_subdirectory(plugins/input/sqlite)
endif()

if (WITH_INPUT_TOPOJSON)
    add_subdirectory(plugins/input/topojson)
endif()

if (WITH_INPUTS)
    message(STATUS "Input plugins:")
    if(WITH_INPUT_CSV      )
        message(STATUS "   - csv     ")
    endif()
    if(WITH_INPUT_GDAL     )
        message(STATUS "   - gdal    ")
    endif()
    if(WITH_INPUT_GEOBUF   )
        message(STATUS "   - geobuf  ")
    endif()
    if(WITH_INPUT_GEOJSON  )
        message(STATUS "   - geojson ")
    endif()
    if(WITH_INPUT_OGR      )
        message(STATUS "   - ogr     ")
    endif()
    if(WITH_INPUT_PGRASTER )
        message(STATUS "   - pgraster")
    endif()
    if(WITH_INPUT_POSTGIS  )
        message(STATUS "   - postgis ")
    endif()
    if(WITH_INPUT_RASTER   )
        message(STATUS "   - raster  ")
    endif()
    if(WITH_INPUT_SHAPE    )
        message(STATUS "   - shape   ")
    endif()
    if(WITH_INPUT_SQLITE   )
        message(STATUS "   - sqlite  ")
    endif()
    if(WITH_INPUT_TOPOJSON )
        message(STATUS "   - topojson")
    endif()
else()
    message(STATUS "Input plugins OFF")
endif()

if(WITH_DEMO)
    add_subdirectory(demo/c++)
endif()

if(WITH_VIEWER)
    find_package(Qt5 COMPONENTS Widgets REQUIRED)
    add_subdirectory(demo/viewer)
endif()

if(WITH_UTILS)
    add_subdirectory(utils/mapnik-render)
    add_subdirectory(utils/shapeindex)
endif()




include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/MapnikConfigVersion.cmake"
  VERSION ${MAPNIK_VERSION}
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/MapnikConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/MapnikConfig.cmake"
  INSTALL_DESTINATION lib/cmake/mapnik
)

install(FILES
          "${CMAKE_CURRENT_BINARY_DIR}/MapnikConfig.cmake"
          "${CMAKE_CURRENT_BINARY_DIR}/MapnikConfigVersion.cmake"
        DESTINATION lib/cmake/mapnik
)