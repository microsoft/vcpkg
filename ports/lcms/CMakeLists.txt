cmake_minimum_required(VERSION 3.5)

project(lcms)
include (GNUInstallDirs)

set(SRCS
"src/cmstypes.c"
"src/cmsvirt.c"
"src/cmswtpnt.c"
"src/cmsxform.c"
"src/lcms2.def"
"src/lcms2_internal.h"
"src/cmsalpha.c"
"src/cmscam02.c"
"src/cmscgats.c"
"src/cmscnvrt.c"
"src/cmserr.c"
"src/cmsgamma.c"
"src/cmsgmt.c"
"src/cmshalf.c"
"src/cmsintrp.c"
"src/cmsio0.c"
"src/cmsio1.c"
"src/cmslut.c"
"src/cmsmd5.c"
"src/cmsmtrx.c"
"src/cmsnamed.c"
"src/cmsopt.c"
"src/cmspack.c"
"src/cmspcs.c"
"src/cmsplugin.c"
"src/cmsps2.c"
"src/cmssamp.c"
"src/cmssm.c"
)

set(CMAKE_DEBUG_POSTFIX d)

add_definitions(-DUNICODE -D_UNICODE)

if(BUILD_SHARED_LIBS)
    add_definitions(-DCMS_DLL_BUILD)
endif()

string(REPLACE "/utf-8" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

set(target_name lcms2)

add_library(${target_name} ${SRCS})

target_include_directories (${target_name}
    PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include"
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(NOT SKIP_INSTALL_HEADERS )
    install(FILES 
        "./include/lcms2.h" 
        "./include/lcms2_plugin.h"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif(NOT SKIP_INSTALL_HEADERS )

install(TARGETS ${target_name} EXPORT "${target_name}-targets"
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install (EXPORT "${target_name}-targets"
    FILE "${target_name}-targets.cmake"
    NAMESPACE ${target_name}::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)

configure_file(${target_name}-config.cmake.in "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake" @ONLY)
install(FILES
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${target_name}-config.cmake"
  DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${target_name}"
)

