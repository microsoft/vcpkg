cmake_minimum_required(VERSION 3.19)

project(blake3 LANGUAGES C)

add_library(blake3)

target_sources(blake3 PRIVATE
    c/blake3.c
    c/blake3_dispatch.c
    c/blake3_portable.c
)

# This is a bit too exotic to be worth supporting right now
target_compile_definitions(blake3 PRIVATE BLAKE3_NO_AVX512=1)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    target_sources(blake3 PRIVATE
        c/blake3_avx2.c
        c/blake3_sse2.c
        c/blake3_sse41.c
    )
    if (NOT MSVC)
        set_source_files_properties(c/blake3_avx2.c COMPILE_FLAGS -mavx2)
        set_source_files_properties(c/blake3_sse2.c COMPILE_FLAGS -msse2)
        set_source_files_properties(c/blake3_sse41.c COMPILE_FLAGS -msse4.1)
    endif()
else()
    target_compile_definitions(blake3 PRIVATE BLAKE3_NO_SSE2=1 BLAKE3_NO_SSE41=1 BLAKE3_NO_AVX2=1)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    target_compile_definitions(blake3 PRIVATE BLAKE3_USE_NEON=1)
    target_sources(blake3 PRIVATE
        c/blake3_neon.c
    )
else()
    target_compile_definitions(blake3 PRIVATE BLAKE3_NO_NEON=1)
endif()

install(TARGETS blake3)
install(FILES c/blake3.h DESTINATION include)
