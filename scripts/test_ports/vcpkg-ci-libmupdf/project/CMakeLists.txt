cmake_minimum_required(VERSION 3.10)
project(libmupdf-test C)

# Dependencies should eventually be provided CMake config package
find_path(MUPDF_INCLUDE_DIR NAMES mupdf/memento.h REQUIRED)
find_library(MUPDF_LIBRARY NAMES libmupdfd libmupdf NAMES_PER_DIR REQUIRED)

add_executable(mu-office-test "${SOURCE_PATH}/source/tests/mu-office-test.c")
target_include_directories(mu-office-test PRIVATE "${MUPDF_INCLUDE_DIR}")
target_link_libraries(mu-office-test PRIVATE "${MUPDF_LIBRARY}")

if(NOT WIN32)
    target_include_directories(mu-office-test AFTER PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
endif()

# Copied from port/libmupdf/CMakeLists.txt, but
# dependencies should eventually be provided CMake config package
find_package(freetype CONFIG REQUIRED)
find_package(JPEG REQUIRED)
find_package(harfbuzz CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec NAMES_PER_DIR)
target_link_libraries(mu-office-test
  PRIVATE
    $<LINK_ONLY:freetype>
    $<LINK_ONLY:harfbuzz::harfbuzz>
    $<LINK_ONLY:openjp2>
    $<LINK_ONLY:JPEG::JPEG>
    ${JBIG2DEC_LIB}
    $<LINK_ONLY:ZLIB::ZLIB>
)
# Missing even in port/libmupdf/CMakeLists.txt
find_package(unofficial-gumbo CONFIG REQUIRED)
target_link_libraries(mu-office-test PRIVATE unofficial::gumbo::gumbo)
if(NOT WIN32)
    target_link_libraries(mu-office-test PRIVATE m)
endif()
