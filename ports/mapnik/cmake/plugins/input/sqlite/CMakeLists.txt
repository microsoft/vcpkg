add_library(mapnik-input-sqlite SHARED
    sqlite_datasource.cpp
    sqlite_featureset.cpp)

target_link_libraries(mapnik-input-sqlite PUBLIC mapnik SQLite::SQLite3)
set_target_properties(mapnik-input-sqlite PROPERTIES PREFIX "")
set_target_properties(mapnik-input-sqlite PROPERTIES OUTPUT_NAME "sqlite")
set_target_properties(mapnik-input-sqlite PROPERTIES SUFFIX ".input")
install(TARGETS mapnik-input-sqlite DESTINATION bin/plugins/input)