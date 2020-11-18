find_package(odb CONFIG REQUIRED)
add_library(mapnik-input-postgis SHARED 
    postgis_datasource.cpp 
    postgis_featureset.cpp )

target_include_directories(mapnik-input-postgis PRIVATE 
    ${mapnik_include_paths}
    ${MAPBOX_POLYLABEL_INCLUDE_DIRS} 
    ${MAPBOX_GEOMETRY_INCLUDE_DIRS}
    ${MAPBOX_VARIANT_INCLUDE_DIRS}
)
target_link_libraries(mapnik-input-postgis PRIVATE mapnik PostgreSQL::PostgreSQL)
set_target_properties(mapnik-input-postgis PROPERTIES PREFIX "")
set_target_properties(mapnik-input-postgis PROPERTIES OUTPUT_NAME "postgis")
set_target_properties(mapnik-input-postgis PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-postgis DESTINATION bin/plugins/input)
