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

file(GLOB_RECURSE SOURCES "source/*.c")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
add_library(libmupdf ${SOURCES})

target_compile_definitions(libmupdf PRIVATE -DZ_SOLO)
target_include_directories(libmupdf PRIVATE
  include
  generated
  thirdparty/jbig2dec
  thirdparty/libjpeg
  thirdparty/mujs
  thirdparty/openjpeg/src/lib/openjp2
  ${JPEG_INCLUDE_DIR}
  ${HARFBUZZ_INCLUDE}
)
target_link_libraries(libmupdf PRIVATE
  freetype
  ${JPEG_LIBRARIES}
  ${HARFBUZZ_LIBRARIES}
)

install(TARGETS libmupdf
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
