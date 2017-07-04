cmake_minimum_required(VERSION 3.5.1)
project(libconfig C CXX)


if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-Dscandir=libconfig_scandir)
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
add_library(libconfig++ ${CPP_SOURCES})

target_link_libraries(libconfig++ libconfig)

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

file(READ   lib/libconfig.h++ LIBCONFIGXX_H)
file(READ   lib/libconfig.h LIBCONFIG_H)

if(BUILD_SHARED_LIBS)
  string(REPLACE "defined(LIBCONFIGXX_EXPORTS)" "1" LIBCONFIGXX_H "${LIBCONFIGXX_H}")
  string(REPLACE "defined(LIBCONFIG_EXPORTS)" "1" LIBCONFIG_H "${LIBCONFIGXX_H}")
else()
  string(REPLACE "defined(LIBCONFIGXX_STATIC)" "1" LIBCONFIGXX_H "${LIBCONFIGXX_H}")
  string(REPLACE "defined(LIBCONFIG_STATIC)" "1" LIBCONFIG_H "${LIBCONFIG_H}")
endif()

file(WRITE ${PROJECT_BINARY_DIR}/libconfig.h++ ${LIBCONFIGXX_H})
file(WRITE ${PROJECT_BINARY_DIR}/libconfig.h ${LIBCONFIG_H})

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES   ${PROJECT_BINARY_DIR}/libconfig.h++ ${PROJECT_BINARY_DIR}/libconfig.h DESTINATION include)
endif()
