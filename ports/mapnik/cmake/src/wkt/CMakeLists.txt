add_library(mapnik-wkt STATIC
    geometry_to_wkt.cpp
    mapnik_wkt_generator_grammar.cpp
    wkt_factory.cpp
    wkt_grammar_x3.cpp)

target_include_directories(mapnik-wkt PRIVATE
    ${MAPNIK_INCLUDE_PATH}
    ${JPEG_INCLUDE_DIR}
    ${LIBXML2_INCLUDE_DIR}
    ${MAPBOX_POLYLABEL_INCLUDE_DIRS} 
    ${MAPBOX_GEOMETRY_INCLUDE_DIRS}
    ${MAPBOX_VARIANT_INCLUDE_DIRS}
)
target_compile_definitions(mapnik-wkt PRIVATE ${MAPNIK_LIB_DEFINITION})

install(TARGETS mapnik-wkt 
    EXPORT MapnikTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)