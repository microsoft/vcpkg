cmake_minimum_required(VERSION 3.8.0)
project(piex)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(".")

add_library(binary_parse
  src/binary_parse/cached_paged_byte_array.cc
  src/binary_parse/range_checked_byte_ptr.cc
)

add_library(image_type_recognition
  src/image_type_recognition/image_type_recognition_lite.cc
)

target_link_libraries(image_type_recognition binary_parse)
target_compile_features(image_type_recognition PUBLIC cxx_std_11)

add_library(tiff_directory
  src/tiff_directory/tiff_directory.cc
)

target_link_libraries(tiff_directory binary_parse)

add_library(piex
  src/piex.cc
  src/tiff_parser.cc
)

target_link_libraries(piex tiff_directory image_type_recognition binary_parse)
target_compile_features(piex PUBLIC cxx_std_11)

install(
  TARGETS piex
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES src/piex.h src/piex_types.h  DESTINATION include/src)
endif()
