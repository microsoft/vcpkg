cmake_minimum_required(VERSION 3.25)
project(smpeg2 CXX)

find_package(SDL2 CONFIG REQUIRED)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    # some c++ code just assumes memset is available
    add_definitions(-FIstring.h)
endif()
add_definitions(-DNOCONTROLS -DTHREADED_AUDIO)

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

if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(smpeg2 PRIVATE -DDLL_EXPORT)
endif()

target_include_directories(smpeg2 PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    $<INSTALL_INTERFACE:include>
)


if(TARGET SDL2::SDL2)
    target_link_libraries(smpeg2 SDL2::SDL2)
else()
    target_link_libraries(smpeg2 SDL2::SDL2-static)
endif()

install(TARGETS smpeg2
    EXPORT smpeg2-targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(EXPORT smpeg2-targets
    FILE unofficial-smpeg2-config.cmake
    NAMESPACE unofficial::smpeg2::
    DESTINATION share/unofficial-smpeg2
)

if(NOT DEFINED SMPEG_SKIP_HEADERS)
    install(FILES smpeg.h MPEGframe.h DESTINATION include)
endif()
