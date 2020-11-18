add_library(mapnik-input-topojson SHARED
    topojson_datasource.cpp
    topojson_featureset.cpp)

target_link_libraries(mapnik-input-topojson PUBLIC mapnik mapnik-json)
set_target_properties(mapnik-input-topojson PROPERTIES PREFIX "")
set_target_properties(mapnik-input-topojson PROPERTIES OUTPUT_NAME "topojson")
set_target_properties(mapnik-input-topojson PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-topojson DESTINATION bin/plugins/input)