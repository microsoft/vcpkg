add_library(mapnik-wkt STATIC
    geometry_to_wkt.cpp
    mapnik_wkt_generator_grammar.cpp
    wkt_factory.cpp
    wkt_grammar_x3.cpp)

install(TARGETS mapnik-wkt LIBRARY DESTINATION lib)
target_compile_definitions(mapnik-json PRIVATE ${MAPNIK_LIB_DEFINITION})