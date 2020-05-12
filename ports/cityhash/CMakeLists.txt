cmake_minimum_required(VERSION 3.13)
project(cityhash CXX)

add_library(cityhash STATIC src/city.cc)

target_include_directories(cityhash PUBLIC
	$<INSTALL_INTERFACE:include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)

install(TARGETS cityhash EXPORT cityhash-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT cityhash-config DESTINATION share/cmake/cityhash)
install(FILES src/city.h DESTINATION include)
