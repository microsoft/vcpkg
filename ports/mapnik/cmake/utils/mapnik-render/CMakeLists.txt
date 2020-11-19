add_executable(mapnik-render mapnik-render.cpp)
target_include_directories(mapnik-render PRIVATE 
    ${mapnik_include_paths}
)
target_link_libraries(mapnik-render PRIVATE mapnik)
install(TARGETS mapnik-render DESTINATION bin)
