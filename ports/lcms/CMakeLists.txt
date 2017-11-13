cmake_minimum_required(VERSION 3.5)

project(lcms)

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

include_directories(
"./include"
)

add_library(lcms2 ${SRCS})

if(NOT SKIP_INSTALL_HEADERS )

  install(FILES 
    "./include/lcms2.h" 
    "./include/lcms2_plugin.h"
    DESTINATION include
	)

endif(NOT SKIP_INSTALL_HEADERS )

install(TARGETS lcms2 EXPORT lcms_EXPORT    
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
