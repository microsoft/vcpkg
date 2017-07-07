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

include_directories(src visual_studio)

add_library(libmatio  ${SRC})

include_directories(${COMMON_INCLUDES})

add_definitions(
  -DH5_NO_DEPRECATED_SYMBOLS
  -DMAT73=1 -DREPLACE_GETOPT
  -DMATIO_HAVE_INTTYPES_H=1
  -DMATIO_HAVE_STDINT_H=1
)

if(BUILD_SHARED_LIBS)
  add_definitions (-DH5_BUILT_AS_DYNAMIC_LIB)
else()
  add_definitions(-DH5_BUILT_AS_STATIC_LIB)
endif()

find_package(ZLIB REQUIRED)

include_directories( ${ZLIB_INCLUDE_DIRS} )
target_link_libraries(libmatio ${ZLIB_LIBRARIES})
add_definitions(-DHAVE_ZLIB=1)

find_package(HDF5 REQUIRED)

include_directories( ${HDF5_INCLUDE_DIRS} )
target_link_libraries(libmatio ${HDF5_C_LIBRARIES})
add_definitions(-DHAVE_HDF5=1)

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
