cmake_minimum_required(VERSION 2.6)
project(SMPEG2 CXX)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

include_directories(${SDL_INCLUDE_DIR})
include_directories(${SDL_INCLUDE_DIR}/SDL2)
include_directories(${CMAKE_SOURCE_DIR})

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()
add_definitions(-DNOCONTROLS -DTHREADED_AUDIO)

# some c++ code just assumes memset is available
file(WRITE ${CMAKE_SOURCE_DIR}/declare_memset.h "#include <string.h>\n")
add_definitions(-FIdeclare_memset.h)

add_library(smpeg2
    audio/bitwindow.cpp
    audio/filter.cpp
    audio/filter_2.cpp
    audio/hufftable.cpp
    audio/mpeglayer1.cpp
    audio/mpeglayer2.cpp
    audio/mpeglayer3.cpp
    audio/mpegtable.cpp
    audio/mpegtoraw.cpp
    audio/MPEGaudio.cpp
    video/decoders.cpp
    video/floatdct.cpp
    video/gdith.cpp
    video/jrevdct.cpp
    video/motionvec.cpp
    video/parseblock.cpp
    video/readfile.cpp
    video/util.cpp
    video/video.cpp
    video/MPEGvideo.cpp
    MPEG.cpp
    MPEGlist.cpp
    MPEGring.cpp
    MPEGstream.cpp
    MPEGsystem.cpp
    smpeg.cpp)

set_target_properties(smpeg2 PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
if(BUILD_SHARED_LIBS)
    target_link_libraries(smpeg2 SDL2::SDL2)
else()
    target_link_libraries(smpeg2 SDL2::SDL2-static)
endif()

install(TARGETS smpeg2
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT DEFINED SMPEG_SKIP_HEADERS)
    install(FILES smpeg.h MPEGframe.h DESTINATION include)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${SDL_LIBRARY})
