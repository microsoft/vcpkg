cmake_minimum_required (VERSION 3.9)
project (tre)

set (HEADERS
    lib/regex.h
    include/tre/tre.h
    include/tre/tre-config.h
)

set (SRCS
    lib/regcomp.c
    lib/regerror.c
    lib/regexec.c
    lib/tre-ast.c
    lib/tre-compile.c
    lib/tre-match-approx.c
    lib/tre-match-backtrack.c
    lib/tre-match-parallel.c
    lib/tre-mem.c
    lib/tre-parse.c
    lib/tre-stack.c
    lib/xmalloc.c
    win32/tre.def
)

include_directories(win32 include/tre)
add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS -DHAVE_CONFIG_H)
if (WIN32)
  add_definitions(-DHAVE_MALLOC_H)
endif()
add_library(tre ${SRCS})

target_include_directories(tre PUBLIC "$<INSTALL_INTERFACE:include>")

install(
  TARGETS tre
  EXPORT unofficial-tre-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(
  EXPORT unofficial-tre-targets
  NAMESPACE unofficial::tre::
  FILE unofficial-tre-config.cmake
  DESTINATION share/unofficial-tre)

install(FILES ${HEADERS} DESTINATION include/tre)
