add_executable(mapnik-demo rundemo.cpp)
add_dependencies(mapnik-demo mapnik)
target_link_libraries(mapnik-demo PRIVATE mapnik)
install(TARGETS mapnik-demo DESTINATION bin)