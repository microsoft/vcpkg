add_library(mapnik-input-raster SHARED
    raster_datasource.cpp
    raster_featureset.cpp
    raster_info.cpp)

target_include_directories(mapnik-input-raster PRIVATE 
    ${mapnik_include_paths}
)
target_link_libraries(mapnik-input-raster PRIVATE mapnik)
set_target_properties(mapnik-input-raster PROPERTIES PREFIX "")
set_target_properties(mapnik-input-raster PROPERTIES OUTPUT_NAME "raster")
set_target_properties(mapnik-input-raster PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-raster DESTINATION bin/plugins/input)