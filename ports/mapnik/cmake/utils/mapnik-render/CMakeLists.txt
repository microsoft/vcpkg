
add_executable(mapnik-render mapnik-render.cpp)
target_link_libraries(mapnik-render PRIVATE mapnik)
install(TARGETS mapnik-render DESTINATION bin)