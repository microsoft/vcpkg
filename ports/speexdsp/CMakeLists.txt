cmake_minimum_required(VERSION 3.1)
option(USE_SSE      "Use SSE"                     OFF)
option(USE_NEON     "Use NEON"                    OFF)
option(FIXED_POINT  "Use Fixed Point Arithmetic"  OFF)

set(LIBSPEEXDSP_VERSION "1.2.0")
set(LIBSPEEXDSP_SOVERSION "1")
project(libspeexdsp)

set(LIBSPEEXDSP_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/buffer.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fftwrap.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/filterbank.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/jitter.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/mdf.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/preprocess.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/resample.c"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/scal.c"
)
set(LIBSPEEXDSP_HEADERS
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/arch.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/bfin.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fftwrap.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/filterbank.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fixed_arm4.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fixed_arm5e.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fixed_bfin.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fixed_debug.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/fixed_generic.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/math_approx.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/misc_bfin.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/os_support.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/pseudofloat.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/resample_neon.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/resample_sse.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/smallft.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/stack_alloc.h"
    "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/vorbis_psy.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speex_buffer.h"
)
set(LIBSPEEXDSP_HEADERS_PUBLIC
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speex_echo.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speex_jitter.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speex_preprocess.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speex_resampler.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/speex/speexdsp_types.h"
)

set(CMAKE_C_VISIBILITY_PRESET hidden)
if (NOT BUILD_SHARED_LIBS)
    add_definitions("-DEXPORT=")
elseif(WIN32)
    add_definitions("-DEXPORT=")
    list(APPEND LIBSPEEXDSP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/win32/libspeexdsp.def")
else()
    add_definitions("-DEXPORT=__attribute__((visibility(\"default\")))")
endif()

if (USE_SSE AND NOT FIXED_POINT)
    add_definitions(-DUSE_SSE -DUSE_SSE2)
endif()
if (USE_NEON AND NOT MSVC)
    add_definitions(-DUSE_NEON)
endif()

if (FIXED_POINT)
    add_definitions(-DFIXED_POINT -DUSE_KISS_FFT)
    list(APPEND LIBSPEEXDSP_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/kiss_fft.c"
        "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/kiss_fftr.c"
    )
    list(APPEND LIBSPEEXDSP_HEADERS
        "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/_kiss_fft_guts.h"
        "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/kiss_fft.h"
        "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/kiss_fftr.h"
    )
else()
    add_definitions(-DFLOATING_POINT -DUSE_SMALLFT)
    list(APPEND LIBSPEEXDSP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/libspeexdsp/smallft.c")
endif()

if (NOT MSVC)
    add_definitions(-DVAR_ARRAYS)
endif()

# Basic speexdsp_config_types.h for Linux support
set(INCLUDE_STDINT "#include <stdint.h>")
set(SIZE16 "int16_t")
set(USIZE16 "uint16_t")
set(SIZE32 "int32_t")
set(USIZE32 "uint32_t")
configure_file("${CMAKE_CURRENT_LIST_DIR}/include/speex/speexdsp_config_types.h.in"
               "${CMAKE_CURRENT_BINARY_DIR}/speexdsp_config_types.h" @ONLY)
list(APPEND LIBSPEEXDSP_HEADERS_PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/speexdsp_config_types.h")

include_directories("${CMAKE_CURRENT_LIST_DIR}/include")
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

add_library(speexdsp ${LIBSPEEXDSP_SOURCES} ${LIBSPEEXDSP_HEADERS})
set_target_properties(speexdsp PROPERTIES PUBLIC_HEADER "${LIBSPEEXDSP_HEADERS_PUBLIC}")
set_target_properties(speexdsp PROPERTIES VERSION "${LIBSPEEXDSP_VERSION}")
set_target_properties(speexdsp PROPERTIES SOVERSION "${LIBSPEEXDSP_SOVERSION}")

# pkgconfig file
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix \${prefix})
SET(bindir \${exec_prefix}/${CMAKE_INSTALL_BINDIR})
SET(libdir \${exec_prefix}/${CMAKE_INSTALL_LIBDIR})
SET(includedir \${prefix}/${CMAKE_INSTALL_INCLUDEDIR})
if(CMAKE_SYSTEM_NAME MATCHES BSD)
  set(PKG_CONFIG_RPATH "-Wl,-R\${libdir}")
endif(CMAKE_SYSTEM_NAME MATCHES BSD)
set(PACKAGE_VERSION "${LIBSPEEXDSP_VERSION}")
configure_file(speexdsp.pc.in speexdsp.pc @ONLY)
install(FILES ${PROJECT_BINARY_DIR}/speexdsp.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

install(TARGETS speexdsp
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include/speex")
