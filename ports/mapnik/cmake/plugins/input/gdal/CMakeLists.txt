add_library(mapnik-input-gdal SHARED
    gdal_datasource.cpp
    gdal_featureset.cpp)

target_link_libraries(mapnik-input-gdal PUBLIC mapnik ${GDAL_LIBRARIES})
set_target_properties(mapnik-input-gdal PROPERTIES PREFIX "")
set_target_properties(mapnik-input-gdal PROPERTIES OUTPUT_NAME "gdal")
set_target_properties(mapnik-input-gdal PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-gdal DESTINATION bin/plugins/input)
