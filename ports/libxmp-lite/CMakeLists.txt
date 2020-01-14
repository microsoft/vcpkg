cmake_minimum_required(VERSION 3.4)
project(libxmp-lite)

set(HEADERS "include/libxmp-lite/xmp.h")

set(SOURCES src/virtual.c
            src/format.c
            src/period.c
            src/player.c
            src/read_event.c
            src/dataio.c
            src/lfo.c
            src/scan.c
            src/control.c
            src/filter.c
            src/effects.c
            src/mixer.c
            src/mix_all.c
            src/load_helpers.c
            src/load.c
            src/hio.c
            src/smix.c
            src/memio.c
            src/loaders/common.c
            src/loaders/itsex.c
            src/loaders/sample.c
            src/loaders/xm_load.c
            src/loaders/mod_load.c
            src/loaders/s3m_load.c
            src/loaders/it_load.c
)

include_directories(include/libxmp-lite src)

option(BUILD_SHARED_LIBS "Build shared libs" OFF)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    option(INSTALL_HEADERS "Install header files" OFF)
else()
    option(INSTALL_HEADERS "Install header files" ON)
endif()

add_library(libxmp-lite ${SOURCES})
target_compile_definitions(libxmp-lite PRIVATE
            LIBXMP_CORE_PLAYER=1
            inline=__inline
            _USE_MATH_DEFINES=1
)

# Fix UWP /sdl compile errors
# Disable C4703: Not initialized
# Disable C4996: Deprecated
set_target_properties(libxmp-lite PROPERTIES COMPILE_FLAGS "/wd4703 /wd4996")

install(
    TARGETS libxmp-lite
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

if(INSTALL_HEADERS)
    install(FILES ${HEADERS} DESTINATION include)
endif()
