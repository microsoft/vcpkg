add_library(mapnik-input-pgraster SHARED 
pgraster_datasource.cpp 
pgraster_featureset.cpp 
pgraster_wkb_reader.cpp)

target_include_directories(mapnik-input-pgraster PRIVATE 
    ${mapnik_include_paths}
)
target_link_libraries(mapnik-input-pgraster PRIVATE mapnik PostgreSQL::PostgreSQL)
set_target_properties(mapnik-input-pgraster PROPERTIES PREFIX "")
set_target_properties(mapnik-input-pgraster PROPERTIES OUTPUT_NAME "pgraster")
set_target_properties(mapnik-input-pgraster PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-pgraster DESTINATION bin/plugins/input)