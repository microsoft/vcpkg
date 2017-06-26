cmake_minimum_required (VERSION 3.8.0)
project (libspeex)

set(COMMON_INCLUDES ${PROJECT_BINARY_DIR}/include)
set(SOURCE_PATH ${PROJECT_SOURCE_DIR})
set(SPEEX_PATH ${SOURCE_PATH}/include/speex)
set(LIBSPEEX_PATH ${SOURCE_PATH}/libspeex)

option(USE_SSE  "USE_SSE  used Note: USE_SSE and FIXED_POINT are mutually exclusive." ON)
if(MSVC)
  add_definitions(-DHAVE_CONFIG_H)
  if(USE_SSE)
    add_definitions(-DUSE_SSE -DFLOATING_POINT)
  else()
    add_definitions(-DFIXED_POINT)
  endif()
endif()


set(LIB_HEADERS
  "${LIBSPEEX_PATH}/cb_search.h"
  "${SOURCE_PATH}/win32/config.h"
  "${LIBSPEEX_PATH}/fftwrap.h"
  "${LIBSPEEX_PATH}/filters.h"
  "${LIBSPEEX_PATH}/filters_sse.h"
  "${LIBSPEEX_PATH}/kiss_fft.h"
  "${LIBSPEEX_PATH}/kiss_fftr.h"
  "${LIBSPEEX_PATH}/lpc.h"
  "${LIBSPEEX_PATH}/arch.h"
  "${LIBSPEEX_PATH}/lsp.h"
  "${LIBSPEEX_PATH}/ltp.h"
  "${LIBSPEEX_PATH}/ltp_sse.h"
  "${LIBSPEEX_PATH}/math_approx.h"
  "${LIBSPEEX_PATH}/modes.h"
  "${LIBSPEEX_PATH}/nb_celp.h"
  "${LIBSPEEX_PATH}/quant_lsp.h"
  "${LIBSPEEX_PATH}/sb_celp.h"
  "${LIBSPEEX_PATH}/stack_alloc.h"
  "${LIBSPEEX_PATH}/vbr.h"
  "${LIBSPEEX_PATH}/vq.h"
)
set(
  SPEEX_HEADERS
  "${SPEEX_PATH}/speex.h"
  "${SPEEX_PATH}/speex_bits.h"
  "${SPEEX_PATH}/speex_callbacks.h"
  "${SPEEX_PATH}/speex_header.h"
  "${SPEEX_PATH}/speex_stereo.h"
  "${SPEEX_PATH}/speex_types.h"
)
set(SRC
  "${LIBSPEEX_PATH}/bits.c"
  "${LIBSPEEX_PATH}/cb_search.c"
  "${LIBSPEEX_PATH}/exc_10_16_table.c"
  "${LIBSPEEX_PATH}/exc_10_32_table.c"
  "${LIBSPEEX_PATH}/exc_20_32_table.c"
  "${LIBSPEEX_PATH}/exc_5_256_table.c"
  "${LIBSPEEX_PATH}/exc_5_64_table.c"
  "${LIBSPEEX_PATH}/exc_8_128_table.c"
  "${LIBSPEEX_PATH}/fftwrap.c"
  "${LIBSPEEX_PATH}/filters.c"
  "${LIBSPEEX_PATH}/gain_table.c"
  "${LIBSPEEX_PATH}/gain_table_lbr.c"
  "${LIBSPEEX_PATH}/hexc_10_32_table.c"
  "${LIBSPEEX_PATH}/hexc_table.c"
  "${LIBSPEEX_PATH}/high_lsp_tables.c"
  "${LIBSPEEX_PATH}/kiss_fft.c"
  "${LIBSPEEX_PATH}/kiss_fftr.c"
  "${LIBSPEEX_PATH}/lpc.c"
  "${LIBSPEEX_PATH}/lsp.c"
  "${LIBSPEEX_PATH}/lsp_tables_nb.c"
  "${LIBSPEEX_PATH}/ltp.c"
  "${LIBSPEEX_PATH}/modes.c"
  "${LIBSPEEX_PATH}/modes_wb.c"
  "${LIBSPEEX_PATH}/nb_celp.c"
  "${LIBSPEEX_PATH}/quant_lsp.c"
  "${LIBSPEEX_PATH}/sb_celp.c"
  "${LIBSPEEX_PATH}/smallft.c"
  "${LIBSPEEX_PATH}/speex.c"
  "${LIBSPEEX_PATH}/speex_callbacks.c"
  "${LIBSPEEX_PATH}/speex_header.c"
  "${LIBSPEEX_PATH}/stereo.c"
  "${LIBSPEEX_PATH}/vbr.c"
  "${LIBSPEEX_PATH}/vq.c"
  "${LIBSPEEX_PATH}/window.c"
)

file(COPY ${LIB_HEADERS} DESTINATION ${COMMON_INCLUDES}/)
file(COPY ${SPEEX_HEADERS} DESTINATION ${COMMON_INCLUDES}/speex)


include_directories(${COMMON_INCLUDES})
add_library (libspeex STATIC ${SRC})


install(
  TARGETS libspeex
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY "${COMMON_INCLUDES}/" DESTINATION include/ FILES_MATCHING PATTERN "*.h")
endif()
