cmake_minimum_required(VERSION 3.0)
project(liblzma)

add_definitions(-DHAVE_CONFIG_H)
if(BUILD_SHARED_LIBS)
    add_definitions(-DLIBLZMADLL_EXPORTS)
    add_definitions(-DDLL_EXPORT)
endif()

include_directories(windows)
include_directories(src/liblzma/common)
include_directories(src/common)
include_directories(src/liblzma/api)
include_directories(src/liblzma/check)
include_directories(src/liblzma/delta)
include_directories(src/liblzma/lz)
include_directories(src/liblzma/lzma)
include_directories(src/liblzma/rangecoder)
include_directories(src/liblzma/simple)

add_library(lzma
    src/common/tuklib_cpucores.c
    src/common/tuklib_physmem.c
    src/liblzma/check/check.c
    src/liblzma/check/crc32_fast.c
    src/liblzma/check/crc32_table.c
    src/liblzma/check/crc64_fast.c
    src/liblzma/check/crc64_table.c
    src/liblzma/check/sha256.c
    src/liblzma/common/alone_decoder.c
    src/liblzma/common/alone_encoder.c
    src/liblzma/common/auto_decoder.c
    src/liblzma/common/block_buffer_decoder.c
    src/liblzma/common/block_buffer_encoder.c
    src/liblzma/common/block_decoder.c
    src/liblzma/common/block_encoder.c
    src/liblzma/common/block_header_decoder.c
    src/liblzma/common/block_header_encoder.c
    src/liblzma/common/block_util.c
    src/liblzma/common/common.c
    src/liblzma/common/easy_buffer_encoder.c
    src/liblzma/common/easy_decoder_memusage.c
    src/liblzma/common/easy_encoder.c
    src/liblzma/common/easy_encoder_memusage.c
    src/liblzma/common/easy_preset.c
    src/liblzma/common/filter_buffer_decoder.c
    src/liblzma/common/filter_buffer_encoder.c
    src/liblzma/common/filter_common.c
    src/liblzma/common/filter_decoder.c
    src/liblzma/common/filter_encoder.c
    src/liblzma/common/filter_flags_decoder.c
    src/liblzma/common/filter_flags_encoder.c
    src/liblzma/common/hardware_cputhreads.c
    src/liblzma/common/hardware_physmem.c
    src/liblzma/common/index.c
    src/liblzma/common/index_decoder.c
    src/liblzma/common/index_encoder.c
    src/liblzma/common/index_hash.c
    src/liblzma/common/outqueue.c
    src/liblzma/common/stream_buffer_decoder.c
    src/liblzma/common/stream_buffer_encoder.c
    src/liblzma/common/stream_decoder.c
    src/liblzma/common/stream_encoder.c
    src/liblzma/common/stream_encoder_mt.c
    src/liblzma/common/stream_flags_common.c
    src/liblzma/common/stream_flags_decoder.c
    src/liblzma/common/stream_flags_encoder.c
    src/liblzma/common/vli_decoder.c
    src/liblzma/common/vli_encoder.c
    src/liblzma/common/vli_size.c
    src/liblzma/delta/delta_common.c
    src/liblzma/delta/delta_decoder.c
    src/liblzma/delta/delta_encoder.c
    src/liblzma/lzma/fastpos_table.c
    src/liblzma/lzma/lzma2_decoder.c
    src/liblzma/lzma/lzma2_encoder.c
    src/liblzma/lzma/lzma_decoder.c
    src/liblzma/lzma/lzma_encoder.c
    src/liblzma/lzma/lzma_encoder_optimum_fast.c
    src/liblzma/lzma/lzma_encoder_optimum_normal.c
    src/liblzma/lzma/lzma_encoder_presets.c
    src/liblzma/lz/lz_decoder.c
    src/liblzma/lz/lz_encoder.c
    src/liblzma/lz/lz_encoder_mf.c
    src/liblzma/rangecoder/price_table.c
    src/liblzma/simple/arm.c
    src/liblzma/simple/armthumb.c
    src/liblzma/simple/ia64.c
    src/liblzma/simple/powerpc.c
    src/liblzma/simple/simple_coder.c
    src/liblzma/simple/simple_decoder.c
    src/liblzma/simple/simple_encoder.c
    src/liblzma/simple/sparc.c
    src/liblzma/simple/x86.c)

install(TARGETS lzma
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT LIBLZMA_SKIP_HEADERS)
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/src/liblzma/api/lzma DESTINATION include)
    install(FILES ${PROJECT_SOURCE_DIR}/src/liblzma/api/lzma.h DESTINATION include)
endif()
