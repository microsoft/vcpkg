add_library(mapnik-json STATIC
    extract_bounding_boxes_x3.cpp
    feature_from_geojson.cpp
    feature_grammar_x3.cpp
    generic_json_grammar_x3.cpp
    geojson_grammar_x3.cpp
    geometry_from_geojson.cpp
    mapnik_feature_to_geojson.cpp
    mapnik_geometry_to_geojson.cpp
    mapnik_json_generator_grammar.cpp
    parse_feature.cpp
    positions_grammar_x3.cpp
    topojson_grammar_x3.cpp
    unicode_string_grammar_x3.cpp)

target_link_libraries(mapnik-json INTERFACE ${ICUU_LIB})

install(TARGETS mapnik-json LIBRARY DESTINATION lib)
target_compile_definitions(mapnik-json PRIVATE ${MAPNIK_LIB_DEFINITION})