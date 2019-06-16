cmake_minimum_required(VERSION 3.9)
project(libmupdf C)

set(CMAKE_DEBUG_POSTFIX d)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include/mupdf/pdf/name-table.h")
  execute_process(
    COMMAND "cmd.exe" "/c" "platform\\win32\\generate.bat"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
endif()

find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_path(HARFBUZZ_INCLUDE hb.h PATH_SUFFIXES harfbuzz)
find_library(HARFBUZZ_LIBRARIES harfbuzz)
find_package(ZLIB REQUIRED)
find_package(openjpeg REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec)

file(GLOB_RECURSE SOURCES "source/*.c" "generated/*.c")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
add_library(libmupdf ${SOURCES})

target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DNO_ICC)
target_include_directories(libmupdf
  PUBLIC
    include
  PRIVATE
    generated
    ${JPEG_INCLUDE_DIR}
    ${HARFBUZZ_INCLUDE}
)
target_link_libraries(libmupdf PRIVATE
  openjp2
  freetype
  ${JPEG_LIBRARIES}
  ${HARFBUZZ_LIBRARIES}
  ${JBIG2DEC_LIB}
  ZLIB::ZLIB
)

install(TARGETS libmupdf
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
