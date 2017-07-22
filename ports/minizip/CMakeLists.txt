cmake_minimum_required(VERSION 3.8)
project(minizip C CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

find_package(ZLIB REQUIRED)

find_package(Bzip2 REQUIRED)

set(MIN_SRC contrib/minizip)

include_directories(${MIN_SRC} ${ZLIB_INCLUDE_DIRS} ${BZIP2_INCLUDE_DIR})

set(SRC
  ${MIN_SRC}/ioapi.c
  ${MIN_SRC}/iowin32.c
  ${MIN_SRC}/unzip.c
  ${MIN_SRC}/zip.c
)
set(HEADERS
  ${MIN_SRC}/ioapi.h
  ${MIN_SRC}/iowin32.h
  ${MIN_SRC}/unzip.h
  ${MIN_SRC}/zip.h
)
if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

add_library(minizip ${SRC})

target_link_libraries(minizip PRIVATE ZLIB::ZLIB)
target_compile_definitions(minizip PRIVATE -D_ZLIB_H)

target_link_libraries(minizip PRIVATE ${BZIP2_LIBRARIES})
target_compile_definitions(minizip PRIVATE -DHAVE_BZIP2=1)

install(
  TARGETS minizip
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${HEADERS} DESTINATION include/minizip)
endif()
