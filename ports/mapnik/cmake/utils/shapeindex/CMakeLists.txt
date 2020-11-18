add_executable(shapeindex shapeindex.cpp)
target_link_libraries(shapeindex PRIVATE mapnik)
target_include_directories(shapeindex PRIVATE ../../plugins/input/shape)
install(TARGETS shapeindex DESTINATION bin)