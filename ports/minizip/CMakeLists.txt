cmake_minimum_required(VERSION 3.8)
project(minizip C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

find_package(ZLIB REQUIRED)

find_package(BZip2 REQUIRED)

set(MIN_SRC contrib/minizip)

include_directories(${MIN_SRC} ${ZLIB_INCLUDE_DIRS} ${BZIP2_INCLUDE_DIR})

set(SRC
  ${MIN_SRC}/ioapi.c
  ${MIN_SRC}/unzip.c
  ${MIN_SRC}/zip.c
  ${MIN_SRC}/unzip.c
  ${MIN_SRC}/mztools.c
)
if(WIN32)
  list(APPEND SRC ${MIN_SRC}/iowin32.c)
endif()

set(HEADERS
  ${MIN_SRC}/crypt.h
  ${MIN_SRC}/ioapi.h
  ${MIN_SRC}/unzip.h
  ${MIN_SRC}/zip.h
  ${MIN_SRC}/unzip.h
  ${MIN_SRC}/mztools.h
)
if(WIN32)
  list(APPEND HEADERS ${MIN_SRC}/iowin32.h)
endif()

add_library(minizip ${SRC})

target_link_libraries(minizip PRIVATE ZLIB::ZLIB)
target_compile_definitions(minizip PRIVATE -D_ZLIB_H)

target_link_libraries(minizip PRIVATE ${BZIP2_LIBRARIES})
target_compile_definitions(minizip PRIVATE -DHAVE_BZIP2=1)

add_executable(minizip_bin  ${MIN_SRC}/minizip.c)
add_executable(miniunz_bin  ${MIN_SRC}/miniunz.c)

target_link_libraries(minizip_bin minizip ${BZIP2_LIBRARIES} ZLIB::ZLIB)
target_link_libraries(miniunz_bin minizip ${BZIP2_LIBRARIES} ZLIB::ZLIB)

set_target_properties(minizip_bin PROPERTIES OUTPUT_NAME minizip)
set_target_properties(miniunz_bin PROPERTIES OUTPUT_NAME miniunz)


install(
  TARGETS minizip
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS minizip_bin miniunz_bin
    RUNTIME DESTINATION tools/minizip
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${HEADERS} DESTINATION include/minizip)
endif()
