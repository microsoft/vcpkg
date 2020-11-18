add_library(mapnik-input-ogr SHARED 
    ogr_converter.cpp
    ogr_datasource.cpp
    ogr_featureset.cpp
    ogr_index_featureset.cpp)

target_include_directories(mapnik-input-ogr PRIVATE 
    ${mapnik_include_paths}
)
target_link_libraries(mapnik-input-ogr PRIVATE mapnik ${OGR_LIBRARIES} ${GDAL_LIBRARIES})
set_target_properties(mapnik-input-ogr PROPERTIES PREFIX "")
set_target_properties(mapnik-input-ogr PROPERTIES OUTPUT_NAME "ogr")
set_target_properties(mapnik-input-ogr PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-ogr DESTINATION bin/plugins/input)
