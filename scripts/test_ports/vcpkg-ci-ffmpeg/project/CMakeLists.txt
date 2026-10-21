cmake_minimum_required(VERSION 3.30)
project(ffmpeg-test C)

find_package(FFMPEG REQUIRED)

add_executable(main main.c)
target_include_directories(main PRIVATE ${FFMPEG_INCLUDE_DIRS})
target_link_directories(main PRIVATE ${FFMPEG_LIBRARY_DIRS})
target_link_libraries(main PRIVATE ${FFMPEG_LIBRARIES})

# FAQ: using the static lib in a shared lib
# https://ffmpeg.org/platform.html#Advanced-linking-configuration
if(UNIX AND NOT BUILD_SHARED_LIBS)
    add_library(shared SHARED main.c)
    target_include_directories(shared PRIVATE ${FFMPEG_INCLUDE_DIRS})
    target_link_directories(shared PRIVATE ${FFMPEG_LIBRARY_DIRS})
    target_link_libraries(shared PRIVATE ${FFMPEG_LIBRARIES})
    if(NOT APPLE)
        target_link_options(shared PRIVATE -Wl,-Bsymbolic)
    endif()
endif()


find_package(PkgConfig REQUIRED)
pkg_check_modules(ffmpeg_pc
    libavcodec libavfilter libavutil libswscale libavdevice libavformat libswresample
    REQUIRED
    IMPORTED_TARGET
)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::ffmpeg_pc
)
