cmake_minimum_required(VERSION 3.5.1)
project(libconfig C CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS -DYY_NO_UNISTD_H -DYY_USE_CONST)
endif()

set(C_SOURCES
  lib/grammar.c
  lib/libconfig.c
  lib/scanctx.c
  lib/scanner.c
  lib/strbuf.c
  lib/strvec.c
  lib/util.c
  lib/wincompat.c
)

set(CPP_SOURCES
  lib/libconfigcpp.cc
)

set(CMAKE_C_STANDARD 99)

include_directories(lib ${STDINT_H})

add_library(libconfig  ${C_SOURCES})
add_library(libconfig++ ${CPP_SOURCES})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libconfig PRIVATE -DLIBCONFIG_EXPORTS)
  target_compile_definitions(libconfig++ PRIVATE -DLIBCONFIGXX_EXPORTS)
else()
  target_compile_definitions(libconfig PUBLIC -DLIBCONFIG_STATIC)
  target_compile_definitions(libconfig++ PUBLIC -DLIBCONFIGXX_STATIC)
endif()

if (WIN32)
  # Linux doesn't have shlwapi
  target_link_libraries(libconfig shlwapi)
endif()
target_link_libraries(libconfig++ PRIVATE libconfig)

install(
  TARGETS libconfig libconfig++
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES lib/libconfig.h++ lib/libconfig.h DESTINATION include)
endif()
