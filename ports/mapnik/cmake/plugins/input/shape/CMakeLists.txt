SET(INPUT_SHAPE_SOURCES
    dbfile.cpp 
    dbf_test.cpp
    shape_datasource.cpp
    shape_featureset.cpp
    shape_index_featureset.cpp
    shape_io.cpp shape_utils.cpp
)
add_library(mapnik-input-shape SHARED ${INPUT_SHAPE_SOURCES})
target_include_directories(mapnik-input-shape PRIVATE 
    ${mapnik_include_paths}
)
target_link_libraries(mapnik-input-shape PRIVATE mapnik)
set_target_properties(mapnik-input-shape PROPERTIES PREFIX "")
set_target_properties(mapnik-input-shape PROPERTIES OUTPUT_NAME "shape")
set_target_properties(mapnik-input-shape PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-shape DESTINATION bin/plugins/input)