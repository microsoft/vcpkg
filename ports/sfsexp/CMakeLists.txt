cmake_minimum_required(VERSION 3.13)
project(sexp)

file(GLOB sources src/*.c src/*.h)

set(header_files "src/cstring.h;src/faststack.h;src/sexp.h;src/sexp_errors.h;src/sexp_memory.h;src/sexp_ops.h;src/sexp_vis.h")

include_directories(src/)

add_library(sexp ${sources})

install(TARGETS sexp
  	ARCHIVE DESTINATION lib
  	LIBRARY DESTINATION lib
  	)
install(FILES ${header_files} DESTINATION include)
