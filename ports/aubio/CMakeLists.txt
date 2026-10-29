cmake_minimum_required(VERSION 3.8)
project(aubio C)

option(WITH_DEPENDENCIES "Adds extra dependencies" ON)
option(BUILD_TOOLS "Build and install tools" ON)

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

if(WITH_DEPENDENCIES)
    add_definitions(
        -DHAVE_SNDFILE=1
        -DHAVE_WAVWRITE=1
        -DHAVE_WAVREAD=1
        -DHAVE_LIBAV=1
        -DHAVE_SWRESAMPLE=1
    )
endif()

set(TOOLS_INSTALLDIR "bin" CACHE STRING "Target directory for installed tools")

if(WITH_DEPENDENCIES)
    find_package(FFMPEG COMPONENTS avcodec avutil avformat swresample REQUIRED)
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

if(WIN32)
    target_compile_definitions(aubio PRIVATE -DHAVE_WIN_HACKS=1)
    target_link_libraries(aubio PUBLIC ws2_32)
endif()

if(BUILD_TOOLS AND WITH_DEPENDENCIES)
    set(EXAMPLE_EXECS aubiomfcc aubionotes aubioonset aubiopitch aubioquiet aubiotrack)
    foreach(EXAMPLE_EXEC ${EXAMPLE_EXECS})
        add_executable(${EXAMPLE_EXEC} examples/${EXAMPLE_EXEC}.c examples/utils.c examples/jackio.c)
        target_link_libraries(${EXAMPLE_EXEC} PRIVATE aubio)
        if(WIN32)
            target_compile_definitions(${EXAMPLE_EXEC} PRIVATE -DHAVE_WIN_HACKS=1)
            target_link_libraries(${EXAMPLE_EXEC} PUBLIC ws2_32)
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
    TARGETS aubio EXPORT AubioTargets
    INCLUDES DESTINATION include
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT AubioTargets NAMESPACE Aubio:: DESTINATION share/aubio)

install(
    DIRECTORY src/
    DESTINATION include/aubio
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*_priv.h" EXCLUDE
    PATTERN "config.h" EXCLUDE
)

# Create CMake configuration export file.
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/AubioConfig.cmake.in "@PACKAGE_INIT@\n")
if(WITH_DEPENDENCIES)
file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/AubioConfig.cmake.in "
    include(CMakeFindDependencyMacro)
    find_dependency(FFMPEG COMPONENTS avcodec avutil avformat swresample REQUIRED)
    find_dependency(BZip2 REQUIRED)
    find_dependency(LibLZMA REQUIRED)
    find_dependency(SndFile REQUIRED)
    ")
endif()
file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/AubioConfig.cmake.in "include(\${CMAKE_CURRENT_LIST_DIR}/AubioTargets.cmake)")

# Install CMake configuration export file.
include(CMakePackageConfigHelpers)
configure_package_config_file(
  ${CMAKE_CURRENT_BINARY_DIR}/AubioConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/AubioConfig.cmake
  INSTALL_DESTINATION share/aubio
)
install(
  FILES
    ${CMAKE_BINARY_DIR}/AubioConfig.cmake
  DESTINATION
    share/aubio
)
