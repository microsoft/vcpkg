cmake_minimum_required(VERSION 3.13)
project(sfsexp)

file(GLOB sources src/*.c src/*.h)
file(GLOB header_files src/*.h)

include_directories(src/)

add_library(sfsexp ${sources})

install(TARGETS sfsexp
  	ARCHIVE DESTINATION lib
  	LIBRARY DESTINATION lib
  	)
install(FILES ${header_files} DESTINATION include)
