cmake_minimum_required(VERSION 3.2)
project(libmpeg2)

option(TOOLS "Build libmpeg2 tools" OFF)

set(MPEG2_SOURCE_FILES
    libmpeg2/alloc.c
    libmpeg2/cpu_accel.c
    libmpeg2/cpu_state.c
    libmpeg2/decode.c
    libmpeg2/header.c
    libmpeg2/idct.c
    libmpeg2/idct_alpha.c
    libmpeg2/idct_altivec.c
    #libmpeg2/idct_mmx.c
    libmpeg2/motion_comp.c
    libmpeg2/motion_comp_alpha.c
    libmpeg2/motion_comp_altivec.c
    libmpeg2/motion_comp_arm.c
    #libmpeg2/motion_comp_mmx.c
    libmpeg2/motion_comp_vis.c
    libmpeg2/slice.c
    )
set(VO_SOURCE_FILES
    libvo/video_out.c
    libvo/video_out_dx.c
    libvo/video_out_null.c
    libvo/video_out_pgm.c
    libvo/video_out_sdl.c
    libvo/video_out_x11.c
    )
set(MPEG2_CONVERT_SOURCES
    libmpeg2/convert/rgb.c
    #libmpeg2/convert/rgb_mmx.c
    libmpeg2/convert/rgb_vis.c
    libmpeg2/convert/uyvy.c
    )
set(GETOPT_FILES
    src/getopt.c
    )
set(HEADERS
    include/mpeg2.h
    include/mpeg2convert.h
    )

add_library(mpeg2 ${MPEG2_SOURCE_FILES})
add_library(mpeg2convert ${MPEG2_CONVERT_SOURCES})
add_library(getopt STATIC ${GETOPT_FILES})
add_library(vo STATIC ${VO_SOURCE_FILES})

target_include_directories(mpeg2convert PUBLIC
    "${CMAKE_SOURCE_DIR}/vc++"
    "${CMAKE_SOURCE_DIR}/include"
    )
target_include_directories(getopt PUBLIC
    "${CMAKE_SOURCE_DIR}/vc++"
    "${CMAKE_SOURCE_DIR}/include"
    )
target_include_directories(vo PUBLIC
    "${CMAKE_SOURCE_DIR}/vc++"
    "${CMAKE_SOURCE_DIR}/include"
    )
target_include_directories(mpeg2 PUBLIC
    "${CMAKE_SOURCE_DIR}/vc++"
    "${CMAKE_SOURCE_DIR}/include"
    )
target_include_directories(mpeg2 INTERFACE
    "${CMAKE_SOURCE_DIR}/include"
    )

target_compile_definitions(getopt PUBLIC HAVE_CONFIG_H)
target_link_libraries(vo mpeg2convert)

if (TOOLS)
    add_executable(mpeg2dec src/mpeg2dec.c src/dump_state.c src/gettimeofday.c)
    add_executable(extract_mpeg2 src/extract_mpeg2.c)
    add_executable(corrupt_mpeg2 src/corrupt_mpeg2.c)

    target_compile_definitions(extract_mpeg2 PUBLIC HAVE_CONFIG_H)
    target_compile_definitions(corrupt_mpeg2 PUBLIC HAVE_CONFIG_H)

    target_link_libraries(mpeg2dec PRIVATE getopt vo mpeg2convert mpeg2 gdi32)
    target_link_libraries(extract_mpeg2 PRIVATE getopt)
    target_link_libraries(corrupt_mpeg2 PRIVATE getopt)

    target_include_directories(mpeg2dec PUBLIC
        "${CMAKE_SOURCE_DIR}/vc++"
        "${CMAKE_SOURCE_DIR}/include"
        "${CMAKE_SOURCE_DIR}/src"
        )
    target_include_directories(extract_mpeg2 PUBLIC
        "${CMAKE_SOURCE_DIR}/vc++"
        "${CMAKE_SOURCE_DIR}/include"
        "${CMAKE_SOURCE_DIR}/src"
        )
    target_include_directories(corrupt_mpeg2 PUBLIC
        "${CMAKE_SOURCE_DIR}/vc++"
        "${CMAKE_SOURCE_DIR}/include"
        "${CMAKE_SOURCE_DIR}/src"
        )
endif (TOOLS)

install(TARGETS mpeg2
    EXPORT libmpeg2
    LIBRARY DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION "include/mpeg2dec")
