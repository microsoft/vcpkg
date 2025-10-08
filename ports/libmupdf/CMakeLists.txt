cmake_minimum_required(VERSION 3.10)
project(libmupdf)

# configuration

set(BIN2COFF_EXECUTABLE "bin2coff" CACHE STRING "Host executable for converter (Windows only)")

option(ENABLE_OCR "Build with OCR" OFF)

# dependencies

find_package(freetype CONFIG REQUIRED)
find_package(JPEG REQUIRED)
find_package(harfbuzz CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec NAMES_PER_DIR)

if (NOT WIN32)
  find_package(Threads REQUIRED)
endif()

if (ENABLE_OCR)
  find_package(Leptonica CONFIG REQUIRED)
  find_package(Tesseract CONFIG REQUIRED)
endif()

# generation of font resources

set(maybe_64bit "")
if (CMAKE_HOST_WIN32 AND WIN32 AND BIN2COFF_EXECUTABLE STREQUAL "bin2coff")
  # cf. scripts/fontdump.nmake
  add_executable(bin2coff EXCLUDE_FROM_ALL scripts/bin2coff.c)
  install(TARGETS bin2coff DESTINATION manual-tools/libmupdf)
  if(CMAKE_SIZEOF_VOID_P EQUAL "8")
    set(maybe_64bit "64bit")
  endif()
endif()

# cf. FONT_BIN in Makefile
# Legal notices should be picked by the portfile.
file(GLOB fonts
  "${PROJECT_SOURCE_DIR}/resources/fonts/urw/*.cff"
  "${PROJECT_SOURCE_DIR}/resources/fonts/han/*.ttc"
  "${PROJECT_SOURCE_DIR}/resources/fonts/droid/DroidSansFallbackFull.ttf"
  "${PROJECT_SOURCE_DIR}/resources/fonts/droid/DroidSansFallback.ttf"
  "${PROJECT_SOURCE_DIR}/resources/fonts/noto/*.otf"
  "${PROJECT_SOURCE_DIR}/resources/fonts/noto/*.ttf"
  "${PROJECT_SOURCE_DIR}/resources/fonts/sil/*.cff"
)
set(FONT_SOURCES "")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/resources")
foreach(font IN LISTS fonts)
  cmake_path(GET font FILENAME name)
  if (CMAKE_HOST_WIN32 AND WIN32)
    string(REGEX REPLACE "[-.]" "_" identifier "_binary_${font}")
    set(font_obj "${CMAKE_CURRENT_BINARY_DIR}/resources/${name}.obj")
    set_source_files_properties("${font_obj}" PROPERTIES EXTERNAL_OBJECT 1)
    add_custom_command(OUTPUT "${font_c_source}"
      COMMAND "${BIN2COFF_EXECUTABLE}" "${font}" "${font_obj}" ${identifier} ${maybe_64bit}
      VERBATIM
    )
    list(APPEND FONT_SOURCES "${font_obj}")
  else()
    set(font_c_source "${CMAKE_CURRENT_BINARY_DIR}/resources/${name}.c")
    add_custom_command(OUTPUT "${font_c_source}"
      COMMAND bash -c "bash ${PROJECT_SOURCE_DIR}/scripts/hexdump.sh '${font}' > '${font_c_source}'"
      VERBATIM
    )
    list(APPEND FONT_SOURCES "${font_c_source}")
  endif()
endforeach()

# actual lib

file(GLOB_RECURSE SOURCES "source/*.c" "generated/*.c")
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/tests/.*.c$")
list(FILTER SOURCES EXCLUDE REGEX "source/fitz/output-docx.c")

if (ENABLE_OCR)
  list(APPEND SOURCES "source/fitz/tessocr.cpp")
endif()

add_library(libmupdf ${SOURCES} ${FONT_SOURCES})
target_include_directories(libmupdf
  PUBLIC
    include
  PRIVATE
    generated
    ${Leptonica_INCLUDE_DIRS}
)
target_compile_definitions(libmupdf
  PRIVATE
    $<$<BOOL:${BUILD_SHARED_LIBS}>:FZ_DLL>
    FZ_ENABLE_BROTLI=0
    FZ_ENABLE_DOCX_OUTPUT=0
    FZ_ENABLE_ICC=0
    FZ_ENABLE_JS=0
    FZ_ENABLE_ODT_OUTPUT=0
    MEMENTO_MUPDF_HACKS
    SHARE_JPEG
    $<$<NOT:$<BOOL:${WIN32}>>:HAVE_PTHREAD>
    $<$<NOT:$<BOOL:${ENABLE_OCR}>>:OCR_DISABLED>
    $<$<BOOL:${ENABLE_OCR}>:HAVE_TESSERACT>
    $<$<BOOL:${ENABLE_OCR}>:HAVE_LEPTONICA>
)
target_link_libraries(libmupdf
  PRIVATE
    freetype
    harfbuzz::harfbuzz
    openjp2
    JPEG::JPEG
    ${JBIG2DEC_LIB}
    ZLIB::ZLIB
)

# installation

install(TARGETS libmupdf
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY include/mupdf
  DESTINATION include
)

if (BUILD_EXAMPLES)
  add_executable(mu-office-test source/tests/mu-office-test.c)
  target_link_libraries(mu-office-test PRIVATE libmupdf)
endif()
