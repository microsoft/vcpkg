add_library(mapnik-input-csv SHARED
    csv_datasource.cpp
    csv_featureset.cpp
    csv_index_featureset.cpp
    csv_inline_featureset.cpp
    csv_utils.cpp)

target_link_libraries(mapnik-input-csv PUBLIC mapnik mapnik-wkt  mapnik-json)
set_target_properties(mapnik-input-csv PROPERTIES PREFIX "")
set_target_properties(mapnik-input-csv PROPERTIES OUTPUT_NAME "csv")
set_target_properties(mapnik-input-csv PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-csv DESTINATION bin/plugins/input)