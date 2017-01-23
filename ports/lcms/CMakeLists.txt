cmake_minimum_required(VERSION 3.5)

project(lcms)

option(SHARED_LIBRARY "use shared library" ON)

set(LIBRARY_TYPE STATIC)
if(SHARED_LIBRARY)
  set(LIBRARY_TYPE SHARED)
endif(SHARED_LIBRARY)

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

add_definitions(-DUNICODE -D_UNICODE)
#string(REPLACE "/utf-8" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

include_directories(
"./include"
)

add_library(lcms ${LIBRARY_TYPE}
${SRCS}
)

if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )

  install(FILES 
    "./include/lcms2.h" 
    "./include/lcms2_plugin.h"
    DESTINATION include
	)

endif(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )

install(TARGETS lcms EXPORT lcms_EXPORT    
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
