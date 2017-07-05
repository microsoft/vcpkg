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

set(
  HEADERS
  src/mat4.h
  src/mat5.h
  src/mat73.h
  src/matio.h
  src/matio_private.h
  visual_studio/matio_pubconf.h
  visual_studio/matioConfig.h
)


add_library(libmatio  ${SRC})


set(COMMON_INCLUDES  ${PROJECT_BINARY_DIR}/includes)

file(COPY ${HEADERS} DESTINATION ${COMMON_INCLUDES})

#fixes issues with relative directories
include_directories(${COMMON_INCLUDES})

option(BUILD_SHARED_LIBRARY ON)

add_definitions(
  -DH5_NO_DEPRECATED_SYMBOLS
  -DMAT73=1 -DREPLACE_GETOPT
  -DMATIO_HAVE_INTTYPES_H=1
  -DMATIO_HAVE_STDINT_H=1
)

if(BUILD_SHARED_LIBRARY)
  add_definitions(-DH5_BUILT_AS_DYNAMIC_LIB)
  set(HDF5_USE_STATIC_LIBRARIES OFF)
else()
  set(HDF5_USE_STATIC_LIBRARIES ON)
endif()

find_package( ZLIB REQUIRED )

if (ZLIB_FOUND)
  include_directories( ${ZLIB_INCLUDE_DIRS} )
  target_link_libraries(libmatio ${ZLIB_LIBRARIES})
  add_definitions(-DHAVE_ZLIB=1)
endif( ZLIB_FOUND )

find_package( HDF5 REQUIRED)

if(HDF5_FOUND)
  include_directories( ${HDF5_INCLUDE_DIRS} )
  target_link_libraries(libmatio ${HDF5_C_LIBRARIES})
  add_definitions(-DHAVE_HDF5=1)
endif()

message(STATUS ${HDF5_C_LIBRARIES})

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
    visual_studio/matioConfig.h
    DESTINATION include
  )
endif()
