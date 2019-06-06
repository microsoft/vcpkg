cmake_minimum_required(VERSION 3.8.0)
project(libmatio C)

set(SRC
  src/endian.c
  src/inflate.c
  src/io.c
  src/mat.c
  src/mat4.c
  src/mat5.c
  src/mat73.c
  visual_studio/matio.def
  src/matvar_cell.c
  src/matvar_struct.c
  src/read_data.c
  src/snprintf.c
)

add_library(libmatio ${SRC})
target_include_directories(libmatio PRIVATE src visual_studio)
target_compile_definitions(libmatio PRIVATE
  -DH5_NO_DEPRECATED_SYMBOLS
  -DMAT73=1
  -DREPLACE_GETOPT
  -DMATIO_HAVE_INTTYPES_H=1
  -DMATIO_HAVE_STDINT_H=1
)

find_package(ZLIB REQUIRED)
target_link_libraries(libmatio PRIVATE ZLIB::ZLIB)
target_compile_definitions(libmatio PRIVATE -DHAVE_ZLIB=1)

find_package(hdf5 CONFIG REQUIRED)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libmatio PRIVATE -DHAVE_HDF5=1 -DH5_BUILT_AS_DYNAMIC_LIB)
  if(HDF5_USE_STATIC_LIBRARIES)
    target_link_libraries(libmatio PRIVATE hdf5::hdf5-static hdf5::hdf5_hl-static)
  else()
    target_link_libraries(libmatio PRIVATE hdf5::hdf5-shared hdf5::hdf5_hl-shared)
  endif()
else()
  target_compile_definitions(libmatio PRIVATE -DHAVE_HDF5=1 -DH5_BUILT_AS_STATIC_LIB)
  target_link_libraries(libmatio PRIVATE hdf5::hdf5-static hdf5::hdf5_hl-static)
endif()

install(
  TARGETS libmatio
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES
    src/matio.h
    visual_studio/matio_pubconf.h
    DESTINATION include
  )
endif()
