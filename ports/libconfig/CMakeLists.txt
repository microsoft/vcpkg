cmake_minimum_required(VERSION 3.5.1)
project(libconfig C CXX)


if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(SOURCE_PATH ${PROJECT_SOURCE_DIR}/lib)
set(COMMON_INCLUDES ${PROJECT_BINARY_DIR}/includes)

set(C_HEADERS
  ${SOURCE_PATH}/grammar.h
  ${SOURCE_PATH}/libconfig.h
  ${SOURCE_PATH}/libconfig.hh
  ${SOURCE_PATH}/parsectx.h
  ${SOURCE_PATH}/scanctx.h
  ${SOURCE_PATH}/scanner.h
  ${SOURCE_PATH}/wincompat.h
  ${SOURCE_PATH}/libconfig.h++
  ${SOURCE_PATH}/libconfigcpp.c++
)

set(
  EXTERNAL_HEADERS ${SOURCE_PATH}/win32
)



set(C_SOURCES
  ${SOURCE_PATH}/grammar.c
  ${SOURCE_PATH}/libconfig.c
  ${SOURCE_PATH}/scanctx.c
  ${SOURCE_PATH}/win32/scandir.c
  ${SOURCE_PATH}/scanner.c
  ${SOURCE_PATH}/strbuf.c
)

set(CPP_SOURCES
  ${SOURCE_PATH}/libconfigcpp.cc
)

file(COPY ${C_HEADERS} DESTINATION ${COMMON_INCLUDES})

include_directories(${COMMON_INCLUDES})
include_directories(${EXTERNAL_HEADERS})

if(BUILD_SHARED)
  add_library(libconfig SHARED ${C_SOURCES})
  add_library(libconfig++ SHARED ${C_SOURCES} ${CPP_SOURCES})
  target_compile_definitions(libconfig PRIVATE  -DLIBCONFIG_EXPORTS -DYY_NO_UNISTD_H -DYY_USE_CONST)
  target_compile_definitions(libconfig++ PRIVATE  -DLIBCONFIG_EXPORTS -DLIBCONFIGXX_EXPORTS -DYY_NO_UNISTD_H -DYY_USE_CONST)
else()
  add_library(libconfig STATIC ${C_SOURCES})
  add_library(libconfig++ STATIC ${C_SOURCES} ${CPP_SOURCES})
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
  install(DIRECTORY "${COMMON_INCLUDES}/" DESTINATION include)
endif()
