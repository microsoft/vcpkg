cmake_minimum_required(VERSION 3.13)
project(libjpeg LANGUAGES C)

option(BUILD_EXECUTABLES OFF)

#
# jconfig.h is a public header, so it must be genrated. Please reference the install.txt in jpegsr9d.zip
#
# jconfig.txt should contain #cmakedefine which is modified by porfile.cmake of ijg-libjpeg port in VcPkg
# By doing this we can skip 'configure' step. Visit https://github.com/LuaDist/libjpeg
#
include(CheckIncludeFile)
check_include_file(stddef.h HAVE_STDDEF_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
configure_file(jconfig.txt ${CMAKE_CURRENT_BINARY_DIR}/jconfig.h)

list(APPEND PUBLIC_HEADERS jpeglib.h jerror.h jmorecfg.h ${CMAKE_CURRENT_BINARY_DIR}/jconfig.h)

add_library(jpeg
    ${PUBLIC_HEADERS} jinclude.h jpegint.h jversion.h
    transupp.h jidctflt.c jidctfst.c jidctint.c jquant1.c jquant2.c jutils.c jmemnobs.c jaricom.c jerror.c jdatadst.c jdatasrc.c 
    jmemsys.h
      jmemmgr.c
    cdjpeg.h cderror.h
      jcmaster.c jcmarker.c jcmainct.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c jcdctmgr.c jchuff.c jcsample.c jctrans.c jcinit.c jcomapi.c jcparam.c jcprepct.c 
      jdmaster.c jdmarker.c jdmainct.c jdapimin.c jdapistd.c jdarith.c jdcoefct.c jdcolor.c jddctmgr.c jdhuff.c jdsample.c jdtrans.c jdinput.c jdmerge.c jdpostct.c
    jdct.h 
      jfdctflt.c jfdctfst.c jfdctint.c
)

if(WIN32)
    target_compile_definitions(jpeg
    PRIVATE
        _CRT_SECURE_NO_WARNINGS
    )
endif()

target_include_directories(jpeg PRIVATE include ${CMAKE_CURRENT_BINARY_DIR})

install(FILES       ${PUBLIC_HEADERS}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include
)
install(TARGETS jpeg
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

if(BUILD_EXECUTABLES)
    add_executable(cjpeg      cdjpeg.c cjpeg.c rdbmp.c rdgif.c rdppm.c rdrle.c rdtarga.c rdswitch.c)
    target_link_libraries(cjpeg PRIVATE jpeg)
    
    add_executable(djpeg      cdjpeg.c djpeg.c wrbmp.c wrgif.c wrppm.c wrrle.c wrtarga.c rdcolmap.c)
    target_link_libraries(djpeg PRIVATE jpeg)
    
    add_executable(jpegtran   jpegtran.c cdjpeg.c rdswitch.c transupp.c)
    target_link_libraries(jpegtran PRIVATE jpeg)
    
    add_executable(rdjpgcom   rdjpgcom.c)
    add_executable(wrjpgcom   wrjpgcom.c)

    install(TARGETS     cjpeg djpeg jpegtran rdjpgcom wrjpgcom
            DESTINATION ${CMAKE_INSTALL_PREFIX}/tools
    )
endif()
