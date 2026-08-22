cmake_minimum_required(VERSION 3.10)
project(libmupdf)

# configuration

set(BIN2COFF_EXECUTABLE "bin2coff" CACHE STRING "Host executable for converter (Windows only)")

option(ENABLE_OCR "Build with OCR" OFF)

# dependencies

find_package(freetype CONFIG REQUIRED)
find_package(harfbuzz CONFIG REQUIRED)
find_package(JPEG REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_package(unofficial-gumbo CONFIG REQUIRED)
find_package(ZLIB REQUIRED)

find_path(JBIG2DEC_INCLUDE_DIR NAMES jbig2.h REQUIRED)
find_library(JBIG2DEC_LIBRARY NAMES jbig2decd jbig2dec NAMES_PER_DIR REQUIRED)

if (ENABLE_OCR)
  find_package(Leptonica CONFIG REQUIRED)
  find_package(Tesseract CONFIG REQUIRED)
endif()

# generation of font resources

if (CMAKE_HOST_WIN32 AND WIN32)
  if(BIN2COFF_EXECUTABLE STREQUAL "bin2coff")
    # cf. scripts/fontdump.nmake
    add_executable(bin2coff EXCLUDE_FROM_ALL scripts/bin2coff.c)
    install(TARGETS bin2coff DESTINATION manual-tools/libmupdf)
  endif()
  # cf. scripts/bin2coff.c
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
    set(coff_arch "Win32")
  elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
    set(coff_arch "aarch64")
  else()
    set(coff_arch "x64")
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
    string(REGEX REPLACE "[-.]" "_" identifier "_binary_${name}")
    set(font_object "${CMAKE_CURRENT_BINARY_DIR}/resources/${name}.obj")
    set_source_files_properties("${font_object}" PROPERTIES EXTERNAL_OBJECT 1)
    add_custom_command(OUTPUT "${font_object}"
      COMMAND "${BIN2COFF_EXECUTABLE}" "${font}" "${font_object}" "${identifier}" ${coff_arch}
      VERBATIM
    )
    list(APPEND FONT_SOURCES "${font_object}")
  else()
    set(font_c_source "${CMAKE_CURRENT_BINARY_DIR}/resources/${name}.c")
    add_custom_command(OUTPUT "${font_c_source}"
      COMMAND bash -c "bash ${PROJECT_SOURCE_DIR}/scripts/hexdump.sh '${font}' > '${font_c_source}'"
      VERBATIM
    )
    list(APPEND FONT_SOURCES "${font_c_source}")
  endif()
endforeach()

# libmupdf

# cf. Makefile, libmupdf.vcxproj
file(GLOB_RECURSE SOURCES
  "source/fitz/*.c" # omitting unused *.cpp
  "source/pdf/*.c"
  "source/xps/*.c"
  "source/svg/*.c"
  "source/html/*.c"
  "source/reflow/*.c"
  "source/cbz/*.c"
)

if (ENABLE_OCR)
  list(APPEND SOURCES "source/fitz/tessocr.cpp")
endif()

add_library(libmupdf ${SOURCES} ${FONT_SOURCES})
set_target_properties(libmupdf PROPERTIES PREFIX "")
target_include_directories(libmupdf
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${JBIG2DEC_INCLUDE_DIR}
    ${Leptonica_INCLUDE_DIRS}
)
target_compile_definitions(libmupdf
  INTERFACE
    $<$<BOOL:${BUILD_SHARED_LIBS}>:FZ_DLL_CLIENT>
  PRIVATE
    $<$<BOOL:${BUILD_SHARED_LIBS}>:FZ_DLL>
    FZ_ENABLE_BROTLI=0        # needs brotli
    FZ_ENABLE_DOCX_OUTPUT=0   # needs https://github.com/ArtifexSoftware/extract
    FZ_ENABLE_ICC=0           # needs lcsm2
    FZ_ENABLE_JS=0            # needs mujs
    FZ_ENABLE_ODT_OUTPUT=0    # needs FZ_ENABLE_DOCX_OUTPUT
    MEMENTO_MUPDF_HACKS
    SHARE_JPEG
    $<$<NOT:$<BOOL:${ENABLE_OCR}>>:OCR_DISABLED>
    $<$<BOOL:${ENABLE_OCR}>:HAVE_TESSERACT>
    $<$<BOOL:${ENABLE_OCR}>:HAVE_LEPTONICA>
)
target_link_libraries(libmupdf
  PRIVATE
    freetype
    harfbuzz::harfbuzz
    ${JBIG2DEC_LIBRARY}
    JPEG::JPEG
    openjp2
    unofficial::gumbo::gumbo
    ZLIB::ZLIB
    $<$<BOOL:${ENABLE_OCR}>:leptonica>
    $<$<BOOL:${ENABLE_OCR}>:Tesseract::libtesseract>
    $<$<BOOL:${ANDROID}>:log>
)

# installation

install(DIRECTORY include/mupdf
  DESTINATION include
)
install(TARGETS libmupdf
  EXPORT unofficial-libmupdf-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(EXPORT unofficial-libmupdf-targets
  NAMESPACE unofficial::libmupdf::
  DESTINATION share/unofficial-libmupdf
)
configure_file(unofficial-libmupdf-config.cmake.in unofficial-libmupdf-config.cmake @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libmupdf-config.cmake"
  DESTINATION share/unofficial-libmupdf
)
