cmake_minimum_required(VERSION 3.5)

option(CMAKE_VERBOSE_MAKEFILE "Create verbose makefile" OFF)
option(BUILD_SHARED_LIBS "Create lcms as a shared library" ON)

project(little-cms)

set(CMAKE_DEBUG_POSTFIX d)

add_library(lcms
    "${CMAKE_CURRENT_LIST_DIR}/src/cmstypes.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsvirt.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmswtpnt.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsxform.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/lcms2.def"
    "${CMAKE_CURRENT_LIST_DIR}/src/lcms2_internal.h"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsalpha.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmscam02.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmscgats.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmscnvrt.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmserr.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsgamma.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsgmt.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmshalf.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsintrp.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsio0.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsio1.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmslut.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsmd5.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsmtrx.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsnamed.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsopt.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmspack.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmspcs.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsplugin.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmsps2.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmssamp.c"
    "${CMAKE_CURRENT_LIST_DIR}/src/cmssm.c"
)

if(BUILD_SHARED_LIBS)
    target_compile_options(lcms PRIVATE -DCMS_DLL_BUILD)
    target_compile_options(lcms PUBLIC -DCMS_DLL)
endif()
target_compile_options(lcms PRIVATE -DUNICODE -D_UNICODE)

target_include_directories(lcms PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include")
set_target_properties(lcms PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_LIST_DIR}/include/lcms2.h;${CMAKE_CURRENT_LIST_DIR}/include/lcms2_plugin.h")

install(TARGETS lcms
    EXPORT lcmsConfig
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    PUBLIC_HEADER DESTINATION "include"
    COMPONENT dev
)

export(TARGETS lcms
    NAMESPACE lcms::
    FILE "share/lcms/lcmsConfig.cmake"
)

install(EXPORT lcmsConfig
    DESTINATION "share/lcms"
    NAMESPACE lcms::
)
