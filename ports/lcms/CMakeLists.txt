cmake_minimum_required(VERSION 3.5)

option(CMAKE_VERBOSE_MAKEFILE "Create verbose makefile" OFF)
option(BUILD_SHARED_LIBS "Create lcms2 as a shared library" ON)

project(little-cms)

set(CMAKE_DEBUG_POSTFIX d)

add_library(lcms2
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
    target_compile_options(lcms2 PRIVATE -DCMS_DLL_BUILD)
    target_compile_options(lcms2 PUBLIC -DCMS_DLL)
endif()
target_compile_options(lcms2 PRIVATE -DUNICODE -D_UNICODE)

target_include_directories(lcms2 PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include")
set_target_properties(lcms2 PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_LIST_DIR}/include/lcms2.h;${CMAKE_CURRENT_LIST_DIR}/include/lcms2_plugin.h")

# Generate pkg-config file
SET(PACKAGE "lcms2")
# Read VERSION from file configure
file(READ "${CMAKE_CURRENT_LIST_DIR}/configure" lcms2_configure)
string(REGEX MATCH "PACKAGE_VERSION='(([0-9]+)\\.([0-9]+))'" _ ${lcms2_configure})
set(VERSION "${CMAKE_MATCH_1}")
SET(prefix "${CMAKE_INSTALL_PREFIX}")
SET(exec_prefix "\${prefix}")
SET(libdir "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
SET(includedir "\${prefix}/include")
CONFIGURE_FILE(lcms2.pc.in "${PROJECT_BINARY_DIR}/lcms2.pc" @ONLY)
IF(CMAKE_BUILD_TYPE MATCHES Debug)
    # Add CMAKE_DEBUG_POSTFIX
    file(READ "${PROJECT_BINARY_DIR}/lcms2.pc" LCMS2_PC)
    string(REPLACE "-llcms2" "-llcms2${CMAKE_DEBUG_POSTFIX}" LCMS2_PC "${LCMS2_PC}")
    file(WRITE "${PROJECT_BINARY_DIR}/lcms2.pc" "${LCMS2_PC}") 
ENDIF()

install(TARGETS lcms2
    EXPORT lcmsConfig
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    PUBLIC_HEADER DESTINATION "include"
    COMPONENT dev
)

INSTALL(FILES ${PROJECT_BINARY_DIR}/lcms2.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

export(TARGETS lcms2
    NAMESPACE lcms2::
    FILE "share/lcms/lcmsConfig.cmake"
)

install(EXPORT lcmsConfig
    DESTINATION "share/lcms"
    NAMESPACE lcms2::
)
