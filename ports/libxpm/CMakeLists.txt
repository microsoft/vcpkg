project(libxpm)
cmake_minimum_required(VERSION 2.8.12)

add_definitions(-DFOR_MSW)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" 
    CACHE PATH "Installation directory for executables"
)
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" 
    CACHE PATH "Installation directory for libraries"
)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" 
    CACHE PATH "Installation directory for headers"
)

file(GLOB LIBXPM_SRC RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")

set(LIBXPM_SRC
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Attrib.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CrBufFrI.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CrDatFrI.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/create.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CrIFrBuf.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CrIFrDat.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/data.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/hashtab.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Image.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Info.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/misc.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/parse.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/RdFToBuf.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/RdFToDat.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/RdFToI.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/rgb.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/scan.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/simx.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/WrFFrBuf.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/WrFFrDat.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/WrFFrI.c"
)

set(LIBXPM_INC
    "${CMAKE_CURRENT_SOURCE_DIR}/src/XpmI.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/simx.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/rgbtab.h"
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include/X11)

if(BUILD_SHARED_LIBS)
    add_library(libxpm SHARED ${LIBXPM_SRC})
    add_definitions(-DLIBXPM_BUILD_DLL)
else()
    add_library(libxpm STATIC ${LIBXPM_SRC})
endif()

install(TARGETS libxpm
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/include/X11" 
        DESTINATION "${INSTALL_INC_DIR}"
)
install(FILES ${LIBXPM_INC}
        DESTINATION "${INSTALL_INC_DIR}"
)
