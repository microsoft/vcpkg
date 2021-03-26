cmake_minimum_required(VERSION 3.8)
project(aubio C)

option(WITH_DEPENDENCIES "Adds extra dependencies" ON)

add_definitions(
    -DHAVE_STDLIB_H=1
    -DHAVE_STDIO_H=1
    -DHAVE_MATH_H=1
    -DHAVE_STRING_H=1
    -DHAVE_LIMITS_H=1
    -DHAVE_STDARG_H=1
    -DHAVE_ERRNO_H=1
    -DHAVE_C99_VARARGS_MACROS=1

    -D_CRT_SECURE_NO_WARNINGS=1
)

set(CMAKE_DEBUG_POSTFIX d)

option(BUILD_TOOLS "Build and install tools" ON)

set(TOOLS_INSTALLDIR "bin" CACHE STRING "Target directory for installed tools")

if(WITH_DEPENDENCIES)
    find_package(FFMPEG COMPONENTS avcodec avutil avdevice avfilter avformat swresample REQUIRED)
    find_package(BZip2 REQUIRED)
    find_package(LibLZMA REQUIRED)
    find_package(SndFile REQUIRED)

    include_directories(${LIBLZMA_INCLUDE_DIRS})
endif()

include_directories(src)

file(GLOB_RECURSE SOURCES src/*.c)

if(WIN32 AND NOT MINGW)
    set_source_files_properties(src/io/sink_wavwrite.c PROPERTIES COMPILE_FLAGS /FIWinsock2.h)
endif()

add_library(aubio ${SOURCES})
if(WITH_DEPENDENCIES)
    target_link_libraries(aubio PUBLIC
        SndFile::sndfile
        ${FFMPEG_LIBRARIES}
        BZip2::BZip2
        ${LIBLZMA_LIBRARIES}
    )
endif()

if(BUILD_TOOLS AND WITH_DEPENDENCIES)
    set(EXAMPLE_EXECS aubiomfcc aubionotes aubioonset aubiopitch aubioquiet aubiotrack)
    foreach(EXAMPLE_EXEC ${EXAMPLE_EXECS})
        add_executable(${EXAMPLE_EXEC} examples/${EXAMPLE_EXEC}.c examples/utils.c examples/jackio.c)
        target_link_libraries(${EXAMPLE_EXEC} PRIVATE aubio)
        if(WIN32)
            target_compile_definitions(${EXAMPLE_EXEC} PRIVATE -DHAVE_WIN_HACKS=1)
        else()
            target_compile_definitions(${EXAMPLE_EXEC} PRIVATE -DHAVE_UNISTD_H=1)
        endif()
    endforeach()
    # Create and add fake config.h to avoid build errors (file is generated for
    # cross-platform requirements in waf build-system)
    file(WRITE "${CMAKE_BINARY_DIR}/config.h" "")
    include_directories(${CMAKE_BINARY_DIR})

    install(
        TARGETS ${EXAMPLE_EXECS}
        RUNTIME DESTINATION ${TOOLS_INSTALLDIR}
    )
endif()

install(
    TARGETS aubio
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        DIRECTORY src/
        DESTINATION include/aubio
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*_priv.h" EXCLUDE
        PATTERN "config.h" EXCLUDE
    )
endif()
