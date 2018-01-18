cmake_minimum_required(VERSION 3.5)
project(exrtools C CXX)

find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)
find_package(ZLIB REQUIRED)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(OpenEXR REQUIRED)

include_directories(. ${OpenEXR_INCLUDE_DIRS})

set(COMMON_SRCS exrinput.h exrinput.c exroutput.h exroutput.c)
set(exrblur_SOURCES ${COMMON_SRCS} gaussian.h gaussian.c exrblur.c)
set(exrchr_SOURCES  ${COMMON_SRCS} exrchr.c)
set(exricamtm_SOURCES  ${COMMON_SRCS} exricamtm.c)
set(exrnlm_SOURCES  ${COMMON_SRCS} exrnlm.c)
set(exrnormalize_SOURCES  ${COMMON_SRCS} exrnormalize.c)
set(exrpptm_SOURCES  ${COMMON_SRCS} exrpptm.c)
set(exrstats_SOURCES  ${COMMON_SRCS} exrstats.c)
set(exrtopng_SOURCES  ${COMMON_SRCS} pngoutput.h pngoutput.c exrtopng.c)

set(jpegtoexr_SOURCES  ${COMMON_SRCS} jpeginput.h jpeginput.c jpegtoexr.c)

set(pngtoexr_SOURCES  ${COMMON_SRCS} pnginput.h pnginput.c pngtoexr.c)

set(ppmtoexr_SOURCES  ${COMMON_SRCS} ppmtoexr.c)

if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

# Create fake library otherwise will get `ninja: error: unknown target 'install'` in debug mode
add_library(exrtools ${COMMON_SRCS})
target_link_libraries(exrtools PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrblur ${exrblur_SOURCES})
target_link_libraries(exrblur PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrchr ${exrchr_SOURCES})
target_link_libraries(exrchr PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exricamtm	${exricamtm_SOURCES})
target_link_libraries(exricamtm PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrnlm	${exrnlm_SOURCES})
target_link_libraries(exrnlm PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrnormalize	${exrnormalize_SOURCES})
target_link_libraries(exrnormalize PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrpptm ${exrpptm_SOURCES})
target_link_libraries(exrpptm PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrstats	${exrstats_SOURCES})
target_link_libraries(exrstats PRIVATE ${OpenEXR_LIBRARIES})

add_executable(exrtopng	${exrtopng_SOURCES})
target_link_libraries(exrtopng PRIVATE PNG::PNG ${OpenEXR_LIBRARIES} ws2_32)

add_executable(jpegtoexr	${jpegtoexr_SOURCES})
target_link_libraries(jpegtoexr PRIVATE ${JPEG_LIBRARIES} ${OpenEXR_LIBRARIES})
target_include_directories(jpegtoexr PRIVATE ${JPEG_INCLUDE_DIR})


add_executable(pngtoexr ${pngtoexr_SOURCES})
target_link_libraries(pngtoexr PRIVATE PNG::PNG ${OpenEXR_LIBRARIES})

add_executable(ppmtoexr	${ppmtoexr_SOURCES})
target_link_libraries(ppmtoexr PRIVATE ${OpenEXR_LIBRARIES} ws2_32)


install(
  TARGETS exrtools
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS
    exrblur
    exrchr
    exricamtm
    exrnlm
    exrnormalize
    exrpptm
    exrstats
    exrtopng
    jpegtoexr
    pngtoexr
    ppmtoexr
    RUNTIME DESTINATION tools/exrtools
  )
endif()

# create fake headers
if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES exrinput.h exroutput.h  DESTINATION include/exrtools
  )
endif()
