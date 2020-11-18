add_library(mapnik-input-geojson SHARED 
    geojson_datasource.cpp 
    geojson_featureset.cpp 
    geojson_index_featureset.cpp 
    geojson_memory_index_featureset.cpp)
    
target_link_libraries(mapnik-input-geojson PUBLIC mapnik mapnik-json)
set_target_properties(mapnik-input-geojson PROPERTIES PREFIX "")
set_target_properties(mapnik-input-geojson PROPERTIES OUTPUT_NAME "geojson")
set_target_properties(mapnik-input-geojson PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-geojson DESTINATION bin/plugins/input)
