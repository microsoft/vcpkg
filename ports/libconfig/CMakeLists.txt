cmake_minimum_required(VERSION 3.5.1)
project(libconfig C CXX)


if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(C_SOURCES
  lib/grammar.c
  lib/libconfig.c
  lib/scanctx.c
  lib/win32/scandir.c
  lib/scanner.c
  lib/strbuf.c
)

set(CPP_SOURCES
  lib/libconfigcpp.cc
)

include_directories(lib)

find_path(DIRENT_H dirent.h)
find_path(STDINT_H stdint.h)

include_directories(${DIRENT_H})
include_directories(${STDINT_H})

add_library(libconfig  ${C_SOURCES})
add_library(libconfig++ ${C_SOURCES} ${CPP_SOURCES})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libconfig PRIVATE  -DLIBCONFIG_EXPORTS -DYY_NO_UNISTD_H -DYY_USE_CONST)
  target_compile_definitions(libconfig++ PRIVATE  -DLIBCONFIG_EXPORTS -DLIBCONFIGXX_EXPORTS -DYY_NO_UNISTD_H -DYY_USE_CONST)
else()
  target_compile_definitions(libconfig PRIVATE -DLIBCONFIG_STATIC -DYY_NO_UNISTD_H)
  target_compile_definitions(libconfig++ PRIVATE -DLIBCONFIG_STATIC -DYY_NO_UNISTD_H)
endif()

install(
  TARGETS libconfig libconfig++
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES   lib/libconfig.h++ lib/libconfig.h DESTINATION include)
endif()
