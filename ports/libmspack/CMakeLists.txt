cmake_minimum_required(VERSION 3.8)

project(libmspack C)

add_definitions(-DHAVE_CONFIG_H)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

# List the source files
set(LIB_SRC mspack/cabc.c
            mspack/cabd.c
            mspack/chmc.c
            mspack/chmd.c
            mspack/crc32.c
            mspack/hlpc.c
            mspack/hlpd.c
            mspack/kwajc.c
            mspack/kwajd.c
            mspack/litc.c
            mspack/litd.c
            mspack/lzssd.c
            mspack/lzxc.c
            mspack/lzxd.c
            mspack/mszipc.c
            mspack/mszipd.c
            mspack/oabc.c
            mspack/oabd.c
            mspack/qtmd.c
            mspack/system.c
            mspack/szddc.c
            mspack/szddd.c
)

if(BUILD_SHARED_LIBS)
    set(LIB_DEF libmspack.def)
endif()

add_library(libmspack ${LIB_SRC} ${LIB_DEF})

target_include_directories(libmspack PRIVATE . ./mspack)

install(TARGETS libmspack
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES mspack/mspack.h DESTINATION include)
