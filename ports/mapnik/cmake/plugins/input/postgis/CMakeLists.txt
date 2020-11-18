add_library(mapnik-input-postgis SHARED 
    postgis_datasource.cpp 
    postgis_featureset.cpp )
    
target_link_libraries(mapnik-input-postgis PUBLIC mapnik ${PostgreSQL_LIBRARIES})
set_target_properties(mapnik-input-postgis PROPERTIES PREFIX "")
set_target_properties(mapnik-input-postgis PROPERTIES OUTPUT_NAME "postgis")
set_target_properties(mapnik-input-postgis PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-postgis DESTINATION bin/plugins/input)
