cmake_minimum_required(VERSION 3.13)
project(sexp)

if(MSVC)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS)
endif()

file(GLOB sources src/*.c src/*.h)
include_directories(src/)

add_library(sexp ${sources})

set_target_properties(sexp PROPERTIES PUBLIC_HEADER "src/cstring.h;src/faststack.h;src/sexp.h;src/sexp_errors.h;src/sexp_memory.h;src/sexp_ops.h;src/sexp_vis.h")

install(TARGETS sexp
  	ARCHIVE DESTINATION lib
  	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
	PUBLIC_HEADER DESTINATION include
)