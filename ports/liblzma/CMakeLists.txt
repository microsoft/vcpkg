cmake_minimum_required(VERSION 3.0)
project(liblzma)

add_definitions(-DHAVE_CONFIG_H)
if(BUILD_SHARED_LIBS)
    add_definitions(-DLIBLZMADLL_EXPORTS)
    add_definitions(-DDLL_EXPORT)
endif()

if(NOT MSVC)
    add_definitions(-DHAVE_VISIBILITY=1)
endif()

if(WIN32)
    include_directories(windows/vs2017)
else()
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/config.h
    """
#define TUKLIB_SYMBOL_PREFIX lzma_
#define ASSUME_RAM 128
#define HAVE_CHECK_CRC32 1
#define HAVE_CHECK_CRC64 1
#define HAVE_CHECK_SHA256 1
#define HAVE_DECODERS 1
#define HAVE_DECODER_ARM 1
#define HAVE_DECODER_ARMTHUMB 1
#define HAVE_DECODER_DELTA 1
#define HAVE_DECODER_IA64 1
#define HAVE_DECODER_LZMA1 1
#define HAVE_DECODER_LZMA2 1
#define HAVE_DECODER_POWERPC 1
#define HAVE_DECODER_SPARC 1
#define HAVE_DECODER_X86 1
#define HAVE_ENCODERS 1
#define HAVE_ENCODER_ARM 1
#define HAVE_ENCODER_ARMTHUMB 1
#define HAVE_ENCODER_DELTA 1
#define HAVE_ENCODER_IA64 1
#define HAVE_ENCODER_LZMA1 1
#define HAVE_ENCODER_LZMA2 1
#define HAVE_ENCODER_POWERPC 1
#define HAVE_ENCODER_SPARC 1
#define HAVE_ENCODER_X86 1
#define HAVE_INTTYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_MF_BT2 1
#define HAVE_MF_BT3 1
#define HAVE_MF_BT4 1
#define HAVE_MF_HC3 1
#define HAVE_MF_HC4 1
#define HAVE_STDBOOL_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_VISIBILITY 1
#define MYTHREAD_POSIX 1
#define PACKAGE_NAME \"XZ Utils\"
#define PACKAGE_URL \"http://tukaani.org/xz/\"
#define SIZEOF_SIZE_T (sizeof(size_t))
""")
endif()
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
