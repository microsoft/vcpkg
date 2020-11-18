
add_library(mapnik-input-geobuf SHARED
geobuf_datasource.cpp
geobuf_featureset.cpp)

find_path(PROTOZERO_INCLUDE_DIRS "protozero/byteswap.hpp")
target_include_directories(mapnik-input-geobuf PRIVATE ${PROTOZERO_INCLUDE_DIRS} ${mapnik_include_paths})
target_link_libraries(mapnik-input-geobuf PRIVATE mapnik)
set_target_properties(mapnik-input-geobuf PROPERTIES PREFIX "")
set_target_properties(mapnik-input-geobuf PROPERTIES OUTPUT_NAME "geobuf")
set_target_properties(mapnik-input-geobuf PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-geobuf DESTINATION bin/plugins/input)