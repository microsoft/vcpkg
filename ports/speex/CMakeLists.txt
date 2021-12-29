cmake_minimum_required (VERSION 3.8.0)
project (libspeex C)

include(GNUInstallDirs)
include(CheckLibraryExists)

option(USE_SSE  "USE_SSE  used Note: USE_SSE and FIXED_POINT are mutually exclusive." ON)
if(MSVC)
  add_definitions(-DHAVE_CONFIG_H)
  if(USE_SSE)
    add_definitions(-DUSE_SSE -DFLOATING_POINT)
  else()
    add_definitions(-DFIXED_POINT)
  endif()
endif()

include_directories(win32 include)

set(CMAKE_DEBUG_POSTFIX d)

file(READ "win32/libspeex.def" _contents)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  string(REPLACE "LIBRARY libspeex" "LIBRARY libspeexd" _contents "${_contents}")
endif()
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libspeex.def"
  "${_contents}\n"
  "speex_nb_mode\n"
  "speex_wb_mode\n"
  "speex_uwb_mode\n"
  "speex_mode_list\n"
  "speex_header_free\n"
)

file(STRINGS "configure.ac"
    _speex_version_defines REGEX "SPEEX_(MAJOR|MINOR|MICRO)_VERSION=([0-9]+)$")
foreach(ver ${_speex_version_defines})
    if(ver MATCHES "SPEEX_(MAJOR|MINOR|MICRO)_VERSION=([0-9]+)$")
        set(SPEEX_${CMAKE_MATCH_1}_VERSION "${CMAKE_MATCH_2}" CACHE INTERNAL "")
    endif()
endforeach()
set(SPEEX_VERSION ${SPEEX_MAJOR_VERSION}.${SPEEX_MINOR_VERSION}.${SPEEX_MICRO_VERSION})

set(SRC
  "libspeex/bits.c"
  "libspeex/cb_search.c"
  "libspeex/exc_10_16_table.c"
  "libspeex/exc_10_32_table.c"
  "libspeex/exc_20_32_table.c"
  "libspeex/exc_5_256_table.c"
  "libspeex/exc_5_64_table.c"
  "libspeex/exc_8_128_table.c"
  "libspeex/fftwrap.c"
  "libspeex/filters.c"
  "libspeex/gain_table.c"
  "libspeex/gain_table_lbr.c"
  "libspeex/hexc_10_32_table.c"
  "libspeex/hexc_table.c"
  "libspeex/high_lsp_tables.c"
  "libspeex/kiss_fft.c"
  "libspeex/kiss_fftr.c"
  "libspeex/lpc.c"
  "libspeex/lsp.c"
  "libspeex/lsp_tables_nb.c"
  "libspeex/ltp.c"
  "libspeex/modes.c"
  "libspeex/modes_wb.c"
  "libspeex/nb_celp.c"
  "libspeex/quant_lsp.c"
  "libspeex/sb_celp.c"
  "libspeex/smallft.c"
  "libspeex/speex.c"
  "libspeex/speex_callbacks.c"
  "libspeex/speex_header.c"
  "libspeex/stereo.c"
  "libspeex/vbr.c"
  "libspeex/vq.c"
  "libspeex/window.c"
  "${CMAKE_CURRENT_BINARY_DIR}/libspeex.def"
)

add_library(libspeex ${SRC})

install(
  TARGETS libspeex
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY include/ DESTINATION include FILES_MATCHING PATTERN "*.h")
endif()

# pkgconfig file
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
set(LIBM )
check_library_exists(m ceil "" LIBMEXIST)
if(LIBMEXIST)
    list(APPEND LIBM -lm)
endif()
set(SPEEXLIB "${CMAKE_PROJECT_NAME}")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(SPEEXLIB "${CMAKE_PROJECT_NAME}d")
endif()
configure_file(speex.pc.in speex.pc @ONLY)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/speex.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
