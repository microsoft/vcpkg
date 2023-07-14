cmake_minimum_required(VERSION 3.9)
project(libmupdf)

option(ENABLE_OCR "Build with OCR" OFF)

set(CMAKE_DEBUG_POSTFIX d)

if(WIN32)
  execute_process(
    COMMAND "cmd.exe" "/c" "platform\\win32\\generate.bat"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
else()
  find_program(MAKE_EXE NAMES make REQUIRED)
  execute_process(
    COMMAND ${MAKE_EXE} "generate"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  )
endif() 


find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_path(HARFBUZZ_INCLUDE hb.h PATH_SUFFIXES harfbuzz)
find_library(HARFBUZZ_LIBRARIES harfbuzz)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec)

if (ENABLE_OCR)
  find_package(Leptonica CONFIG REQUIRED)
  find_package(Tesseract CONFIG REQUIRED)
endif()

file(GLOB_RECURSE SOURCES "source/*.c" "generated/*.c" "source/*.h")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/tests/.*.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/fitz/output-docx.c")

if (ENABLE_OCR)
  list(APPEND SOURCES "source/fitz/tessocr.cpp")
endif()

add_library(libmupdf ${SOURCES})

if(WIN32)
  target_compile_definitions(libmupdf PRIVATE -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
else()
  target_compile_definitions(libmupdf PRIVATE -DHAVE_PTHREAD=1 -DSHARE_JPEG -DFZ_ENABLE_JS=0 -DFZ_ENABLE_ICC=0 -DMEMENTO_MUPDF_HACKS -DFZ_ENABLE_DOCX_OUTPUT=0 -DFZ_ENABLE_ODT_OUTPUT=0)
endif()


if (ENABLE_OCR)
  target_compile_definitions(libmupdf PRIVATE -DHAVE_TESSERACT=1 -DHAVE_LEPTONICA=1)
else()
  target_compile_definitions(libmupdf PRIVATE -DOCR_DISABLED=1)
endif()

target_include_directories(libmupdf
  PUBLIC
    include
  PRIVATE
    generated
    ${JPEG_INCLUDE_DIR}
    ${HARFBUZZ_INCLUDE}
)

if (ENABLE_OCR)
target_include_directories(libmupdf
  PRIVATE
    ${Leptonica_INCLUDE_DIRS}
)
endif()

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
