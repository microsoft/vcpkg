cmake_minimum_required(VERSION 3.0)
project(pixman VERSION 0.34.0 LANGUAGES C)

set(CMAKE_DEBUG_POSTFIX "d")

if(UNIX)
    add_definitions(-DHAVE_PTHREADS)
endif()

include_directories(".")

file(GLOB SOURCES
"pixman.c"
"pixman-access.c"
"pixman-access-accessors.c"
"pixman-bits-image.c"
"pixman-combine32.c"
"pixman-combine-float.c"
"pixman-conical-gradient.c"
"pixman-filter.c"
"pixman-x86.c"
"pixman-mips.c"
"pixman-arm.c"
"pixman-ppc.c"
"pixman-edge.c"
"pixman-edge-accessors.c"
"pixman-fast-path.c"
"pixman-glyph.c"
"pixman-general.c"
"pixman-gradient-walker.c"
"pixman-image.c"
"pixman-implementation.c"
"pixman-linear-gradient.c"
"pixman-matrix.c"
"pixman-noop.c"
"pixman-radial-gradient.c"
"pixman-region16.c"
"pixman-region32.c"
"pixman-solid-fill.c"
"pixman-timer.c"
"pixman-trap.c"
"pixman-utils.c"
)

# pixman requires the three PACKAGE* definitions in order to compile.
set(PIXMAN_DEFS 
    PRIVATE
    PACKAGE="pixman-1"
    PACKAGE_VERSION="0.34.0"
    PACKAGE_BUGREPORT=""
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    # don't enable SSE2 for arm64-windows and arm-windows
else()
    # The USE_SSE2 definition lets it use SSE2 instructions for speed. Every x86/64 target machine should have SSE2 these days.
    set(PIXMAN_DEFS ${PIXMAN_DEFS} USE_SSE2)
    file(GLOB SSE2_SOURCES "pixman-sse2.c")
    set(SOURCES ${SOURCES} ${SSE2_SOURCES})
endif()

add_library(pixman-1 ${SOURCES})
target_include_directories(pixman-1 PUBLIC $<INSTALL_INTERFACE:include>)
target_compile_definitions(pixman-1 ${PIXMAN_DEFS})

if(UNIX AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    target_compile_options(pixman-1 PRIVATE -msse2)
endif()

# pixman produces a lot of warnings which are disabled here because they otherwise fill up the log files
if(MSVC)
    target_compile_options(pixman-1 PRIVATE "/wd4244" "/wd4146" "/wd4996") #  PUBLIC "/D_CRT_SECURE_NO_WARNINGS"
endif()

install(TARGETS pixman-1
  EXPORT pixman-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(
    EXPORT pixman-targets
    NAMESPACE unofficial::pixman::
    FILE unofficial-pixman-config.cmake
    DESTINATION share/unofficial-pixman
)
