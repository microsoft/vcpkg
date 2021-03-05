cmake_minimum_required(VERSION 3.9)

include(CheckCSourceRuns)

file(STRINGS ${CMAKE_CURRENT_LIST_DIR}/configure.ac config_ac_contents)

foreach (line ${config_ac_contents})
    if (line MATCHES "AC_INIT\\(\\[libsodium\\],\\[([0-9.]+)\\],")
        set(VERSION ${CMAKE_MATCH_1})
    elseif (line MATCHES "SODIUM_LIBRARY_VERSION_(MAJOR|MINOR)=([0-9]+)")
        set(SODIUM_LIBRARY_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
    endif ()
endforeach ()

message("VERSION: ${VERSION}")
message("SODIUM_LIBRARY_VERSION_MAJOR: ${SODIUM_LIBRARY_VERSION_MAJOR}")
message("SODIUM_LIBRARY_VERSION_MINOR: ${SODIUM_LIBRARY_VERSION_MINOR}")

project(sodium VERSION ${VERSION} LANGUAGES C ASM)

include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CMakePackageConfigHelpers)
include(CTest)
include(GNUInstallDirs)
include(TestBigEndian)

set(CMAKE_C_STANDARD 99)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

option(BUILD_SHARED_LIBS "Build shared library" ${BUILD_SHARED_LIBS})
option(ENABLE_SSP "Compile with -fstack-protector" ON)
option(ENABLE_PIE "Compile with -fPIE" ON)
option(ENABLE_BLOCKING_RANDOM "Enable blocking random" OFF)
option(ENABLE_MINIMAL "Only compile the minimum set of functions required for the high-level API" OFF)
option(ENABLE_PTHREADS "Use pthreads library" ON)
option(ENABLE_RETPOLINE "Use return trampolines for indirect calls" OFF)

if (ENABLE_MINIMAL)
    set(SODIUM_LIBRARY_MINIMAL_DEF "#define SODIUM_LIBRARY_MINIMAL 1")
endif ()

configure_file(
    src/libsodium/include/sodium/version.h.in
    ${CMAKE_BINARY_DIR}/sodium/version.h
)

file(GLOB sodium_headers
    ${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium/*.h
    ${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium.h
    ${CMAKE_BINARY_DIR}/sodium/version.h
)

if (UNIX)
    file(GLOB_RECURSE sodium_sources
        ${PROJECT_SOURCE_DIR}/src/libsodium/*.c
        ${PROJECT_SOURCE_DIR}/src/libsodium/*.S # HAVE_AVX_ASM
    )
else ()
    file(GLOB_RECURSE sodium_sources
        ${PROJECT_SOURCE_DIR}/src/libsodium/*.c
    ) 
endif ()

if (MSVC)
    enable_language(RC)

    list(APPEND sodium_sources
        builds/msvc/resource.rc
    )
endif ()

add_library(${PROJECT_NAME}
    ${sodium_headers}
    ${sodium_sources}
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES
        PREFIX ""
        OUTPUT_NAME "lib${PROJECT_NAME}"
)

test_big_endian(IS_BIG_ENDIAN)

if (IS_BIG_ENDIAN)
    target_compile_definitions(${PROJECT_NAME} PRIVATE NATIVE_BIG_ENDIAN)
else ()
    target_compile_definitions(${PROJECT_NAME} PRIVATE NATIVE_LITTLE_ENDIAN)
endif ()

macro (sodium_check_func func var)
    check_function_exists(${func} ${var})
    if (${var})
        target_compile_definitions(${PROJECT_NAME} PRIVATE ${var}=1)
    endif ()
endmacro ()

if (MSVC)
    target_compile_options(${PROJECT_NAME}
        PRIVATE
            /D_CONSOLE
            /D_CRT_SECURE_NO_WARNINGS
            /DCPU_UNALIGNED_ACCESS=1
            /MP
            /Dinline=__inline
            /wd4068 # Unknown pragma
            /wd4197
            /wd4244 # Macro redefinition
    )

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
            advapi32
    )
else ()
    if (ENABLE_BLOCKING_RANDOM)
        target_compile_definitions(${PROJECT_NAME} PRIVATE USE_BLOCKING_RANDOM)
    endif ()

    if (ENABLE_PTHREADS)
        target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_PTHREAD)
        target_compile_options(${PROJECT_NAME} PRIVATE -ftls-model=local-dynamic)
        target_compile_options(${PROJECT_NAME} PUBLIC -pthread)
    endif ()

    if (ENABLE_SSP)
        target_compile_options(${PROJECT_NAME} PRIVATE -fstack-protector-all)
    endif ()

    if (ENABLE_PIE)
        target_compile_options(${PROJECT_NAME} PRIVATE -fPIE)
    endif ()

    if (ENABLE_RETPOLINE)
        target_compile_options(${PROJECT_NAME}
            PRIVATE
                -mindirect-branch=thunk-inline
                -mindirect-branch-register
        )
    endif ()

    target_compile_options(${PROJECT_NAME}
        PRIVATE
            -flax-vector-conversions
            -fvisibility=hidden
            -fPIC
            -fwrapv
            -Wall
            -Wextra
            -Wbad-function-cast
            -Wcast-qual
            #-Wdiv-by-zero
            #-Wduplicated-branches
            #-Wduplicated-cond
            -Wfloat-equal
            -Wformat=2
            -Wlogical-op
            -Wmaybe-uninitialized
            #-Wmisleading-indentation
            -Wmissing-declarations
            -Wmissing-prototypes
            -Wnested-externs
            #-Wno-type-limits
            #-Wno-unknown-pragmas
            -Wnormalized=id
            #-Wnull-dereference
            -Wold-style-declaration
            -Wpointer-arith
            -Wredundant-decls
            #-Wrestrict
            #-Wsometimes-uninitialized
            -Wstrict-prototypes
            -Wswitch-enum
            #-Wvariable-decl
            -Wwrite-strings
            -Wl,-z,relro
            -Wl,-z,now
            -Wl,-z,noexecstack
    )

    if (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR
        CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
        target_compile_options(${PROJECT_NAME}
            PRIVATE
                -Wno-unknown-warning-option
                -Wshorten-64-to-32
        )
    endif ()

    check_include_file(sys/mman.h HAVE_SYS_MMAN_H)
    if (HAVE_SYS_MMAN_H)
        target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_SYS_MMAN_H)
    endif ()

    sodium_check_func(arc4random HAVE_SAFE_ARC4RANDOM)
    sodium_check_func(mmap HAVE_MMAP)
    sodium_check_func(mlock HAVE_MLOCK)
    sodium_check_func(madvise HAVE_MADVISE)
    sodium_check_func(mprotect HAVE_MPROTECT)
    sodium_check_func(memset_s HAVE_MEMSET_S)
    sodium_check_func(explicit_bzero HAVE_EXPLICIT_BZERO)
    sodium_check_func(explicit_memset HAVE_EXPLICIT_MEMSET)
    sodium_check_func(nanosleep HAVE_NANOSLEEP)
    sodium_check_func(posix_memalign HAVE_POSIX_MEMALIGN)
    sodium_check_func(getpid HAVE_GETPID)

    if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        check_c_source_runs(
            "
            #pragma GCC target(\"mmx\")
            #include <mmintrin.h>
            int main(void)
            {
              __m64 x = _mm_setzero_si64();
            }
            "
            HAVE_MMINTRIN_H
        )

        if (HAVE_MMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_MMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mmmx)
        endif ()

        check_c_source_runs(
            "
            #pragma GCC target(\"sse2\")
            #ifndef __SSE2__
            # define __SSE2__
            #endif
            
            #include <emmintrin.h>
            int main(void) {
              __m128d x = _mm_setzero_pd();
              __m128i z = _mm_srli_epi64(_mm_setzero_si128(), 26);
            }
            "
            HAVE_EMMINTRIN_H
        )

        if (HAVE_EMMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_EMMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -msse2)
        endif ()

        check_c_source_runs(
            "
            #pragma GCC target(\"sse3\")
            #include <pmmintrin.h>
            int main(void) {
              __m128 x = _mm_addsub_ps(_mm_cvtpd_ps(_mm_setzero_pd()), _mm_cvtpd_ps(_mm_setzero_pd()));
            }
            "
            HAVE_PMMINTRIN_H
        )

        if (HAVE_PMMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_PMMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -msse3)
        endif ()

        check_c_source_runs(
            "
            #pragma GCC target(\"ssse3\")
            #include <tmmintrin.h>
            int main(void) {
              __m64 x = _mm_abs_pi32(_m_from_int(0));
            }
            "
            HAVE_TMMINTRIN_H
        )

        if (HAVE_TMMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_TMMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mssse3)
        endif ()

        check_c_source_runs(
            "
            #pragma GCC target(\"sse4.1\")
            #include <smmintrin.h>
            int main(void) {
              __m128i x = _mm_minpos_epu16(_mm_setzero_si128());
            }
            "
            HAVE_SMMINTRIN_H
        )

        if (HAVE_SMMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_SMMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -msse4.1)
        endif ()

        check_c_source_runs(
            "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX opcodes
            #endif
            #pragma GCC target(\"avx\")
            #include <immintrin.h>
            int main(void) {
              _mm256_zeroall();
            }
            "
            HAVE_AVXINTRIN_H
        )

        if (HAVE_AVXINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_AVXINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mavx)
        endif ()

        check_c_source_runs(
            "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX2 opcodes
            #endif
            #pragma GCC target(\"avx2\")
            #include <immintrin.h>
            int main(void) {
              __m256 x = _mm256_set1_ps(3.14);
              __m256 y = _mm256_permutevar8x32_ps(x, _mm256_set1_epi32(42));
              return _mm256_movemask_ps(_mm256_cmp_ps(x, y, _CMP_NEQ_OQ));
            }
            "
            HAVE_AVX2INTRIN_H
        )

        if (HAVE_AVX2INTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_AVX2INTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mavx2)

            check_c_source_runs(
                "
                #ifdef __native_client__
                # error NativeClient detected - Avoiding AVX2 opcodes
                #endif
                #pragma GCC target(\"avx2\")
                #include <immintrin.h>
                int main(void) {
                  __m256i y = _mm256_broadcastsi128_si256(_mm_setzero_si128());
                }
                "
                _mm256_broadcastsi128_si256_DEFINED
            )

            if (NOT _mm256_broadcastsi128_si256_DEFINED)
                target_compile_definitions(${PROJECT_NAME}
                    PRIVATE
                        _mm256_broadcastsi128_si256=_mm_broadcastsi128_si256
                )
            endif ()
        endif ()

        check_c_source_runs(
            "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AVX512F opcodes
            #endif
            #pragma GCC target(\"avx512f\")
            #include <immintrin.h>
            
            #ifndef __AVX512F__
            # error No AVX512 support
            #elif defined(__clang__)
            # if __clang_major__ < 4
            #  error Compiler AVX512 support may be broken
            # endif
            #elif defined(__GNUC__)
            # if __GNUC__ < 6
            #  error Compiler AVX512 support may be broken
            # endif
            #endif
     
            int main(void) {
              __m512i x = _mm512_setzero_epi32();
              __m512i y = _mm512_permutexvar_epi64(_mm512_setr_epi64(0, 1, 4, 5, 2, 3, 6, 7), x);
            }
            "
            HAVE_AVX512FINTRIN_H
        )

        if (HAVE_AVX512FINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_AVX512FINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mavx512f)
        else ()
            target_compile_options(${PROJECT_NAME} PRIVATE -mno-avx512f)
        endif ()

        check_c_source_runs(
            "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding AESNI opcodes
            #endif
            #pragma GCC target(\"aes\")
            #pragma GCC target(\"pclmul\")
            #include <wmmintrin.h>

            int main(void) {
              __m128i x = _mm_aesimc_si128(_mm_setzero_si128());
              __m128i y = _mm_clmulepi64_si128(_mm_setzero_si128(), _mm_setzero_si128(), 0);
            }
            "
            HAVE_WMMINTRIN_H
        )

        if (HAVE_WMMINTRIN_H)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_WMMINTRIN_H=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -maes -mpclmul)
        endif ()

        check_c_source_runs(
            "
            #ifdef __native_client__
            # error NativeClient detected - Avoiding RDRAND opcodes
            #endif
            #pragma GCC target(\"rdrnd\")
            #include <immintrin.h>

            int main(void) {
              unsigned long long x;
              _rdrand64_step(&x);
            }
            "
            HAVE_RDRAND
        )

        if (HAVE_RDRAND)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_RDRAND=1)
            target_compile_options(${PROJECT_NAME} PRIVATE -mrdrnd)
        endif ()

        check_c_source_runs(
            "
            #include <intrin.h>

            int main(void) {
              (void) _xgetbv(0);
            }
            "
            HAVE__XGETBV
        )

        if (HAVE__XGETBV)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE__XGETBV=1)
        endif ()

        check_c_source_runs(
            "
            int main(void) {
              int a = 42;
              int *pnt = &a;
              __asm__ __volatile__ (\"\" : : \"r\"(pnt) : \"memory\");
            }
            "
            HAVE_INLINE_ASM
        )

        if (HAVE_INLINE_ASM)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_INLINE_ASM=1)
        endif ()

        check_c_source_runs(
            "
            int main(void) {
            #if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
            # if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
            #  error Windows x86_64 calling conventions are not supported yet
            # endif
            /* neat */
            #else
            # error !x86_64
            #endif
              unsigned char i = 0, o = 0, t;
              __asm__ __volatile__ (\"pxor %%xmm12, %%xmm6 \n\"
                \"movb (%[i]), %[t] \n\"
                \"addb %[t], (%[o]) \n\"
                : [t] \"=&r\"(t)
                : [o] \"D\"(&o), [i] \"S\"(&i)
                : \"memory\", \"flags\", \"cc\");
            }
            "
            HAVE_AMD64_ASM
        )

        if (HAVE_AMD64_ASM)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_AMD64_ASM=1)
        endif ()

        check_c_source_runs(
            "
            int main(void) {
            #if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
            # if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
            #  error Windows x86_64 calling conventions are not supported yet
            # endif
            /* neat */
            #else
            # error !x86_64
            #endif
              __asm__ __volatile__ (\"vpunpcklqdq %xmm0,%xmm13,%xmm0\");
            }
            "
            HAVE_AVX_ASM
        )

        if (HAVE_AVX_ASM)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_AVX_ASM=1)
        endif ()

        check_c_source_runs(
            "
            #if !defined(__clang__) && !defined(__GNUC__) && !defined(__SIZEOF_INT128__)
            # error mode(TI) is a gcc extension, and __int128 is not available
            #endif
            #if defined(__clang__) && !defined(__x86_64__) && !defined(__aarch64__)
            # error clang does not properly handle the 128-bit type on 32-bit systems
            #endif
            #ifndef NATIVE_LITTLE_ENDIAN
            # error libsodium currently expects a little endian CPU for the 128-bit type
            #endif
            #ifdef __EMSCRIPTEN__
            # error emscripten currently doesn't support some operations on integers larger than 64 bits
            #endif
            #include <stddef.h>
            #include <stdint.h>
            #if defined(__SIZEOF_INT128__)
            typedef unsigned __int128 uint128_t;
            #else
            typedef unsigned uint128_t __attribute__((mode(TI)));
            #endif
            void fcontract(uint128_t *t) {
              *t += 0x8000000000000 - 1;
              *t *= *t;
              *t >>= 84;
            }

            int main(void) {
              (void) fcontract;
            }
            "
            HAVE_TI_MODE
        )

        if (HAVE_TI_MODE)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_TI_MODE=1)
        endif ()

        check_c_source_runs(
            "
            int main(void) {
              unsigned int cpu_info[4];
              __asm__ __volatile__ (\"xchgl %%ebx, %k1; cpuid; xchgl %%ebx, %k1\" :
                \"=a\" (cpu_info[0]), \"=&r\" (cpu_info[1]),
                \"=c\" (cpu_info[2]), \"=d\" (cpu_info[3]) :
                \"0\" (0U), \"2\" (0U));
            }
            "
            HAVE_CPUID
        )

        if (HAVE_CPUID)
            target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CPUID=1)
        endif ()
    endif ()

    check_c_source_runs(
        "
        #if !defined(__ELF__) && !defined(__APPLE_CC__)
        # error Support for weak symbols may not be available
        #endif
        __attribute__((weak)) void __dummy(void *x) { }
        void f(void *x) { __dummy(x); }
        int main(void) {}
        "
        HAVE_WEAK_SYMBOLS
    )

    if (HAVE_WEAK_SYMBOLS)
        target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_WEAK_SYMBOLS=1)
    endif ()

    check_c_source_runs(
        "
        int main(void) {
          static volatile int _sodium_lock;
          __sync_lock_test_and_set(&_sodium_lock, 1);
          __sync_lock_release(&_sodium_lock);
        }
        "
        HAVE_ATOMIC_OPS
    )

    if (HAVE_ATOMIC_OPS)
        target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_ATOMIC_OPS=1)
    endif ()

    check_c_source_runs(
        "
        #include <limits.h>
        #include <stdint.h>
        int main(void) {
          (void) SIZE_MAX;
          (void) UINT64_MAX;
        }
        "
        STDC_LIMIT_MACROS_REQUIRED
    )

    if (STDC_LIMIT_MACROS_REQUIRED)
        target_compile_definitions(${PROJECT_NAME}
            PRIVATE
                __STDC_LIMIT_MACROS
                __STDC_CONSTANT_MACROS
        )
    endif ()

    # include/sodium/private/common.h
    target_compile_definitions(${PROJECT_NAME} PRIVATE CONFIGURED=1)
endif ()

if (BUILD_SHARED_LIBS)
    if (MSVC)
        target_compile_definitions(${PROJECT_NAME}
            PRIVATE
                SODIUM_DLL_EXPORT
        )
    endif ()
else ()
    target_compile_definitions(${PROJECT_NAME}
        PUBLIC
            SODIUM_STATIC
    )
endif ()

target_include_directories(${PROJECT_NAME}
    PRIVATE
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium>
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/sodium>
)

if (BUILD_TESTING)
    file(GLOB sodium_test_sources ${PROJECT_SOURCE_DIR}/test/default/*.c)

    foreach (test_src ${sodium_test_sources})
        get_filename_component(test_name ${test_src} NAME_WE)
        
        add_executable(${test_name} ${test_src})
        
        if (MSVC)
            target_compile_definitions(${test_name} PRIVATE _CRT_SECURE_NO_WARNINGS)
        endif ()
        
        target_include_directories(${test_name}
            PRIVATE
                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/libsodium/include>
                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium>
                $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/test/quirks>
        )

        target_link_libraries(${test_name} PRIVATE ${PROJECT_NAME})

        add_custom_command(TARGET ${test_name} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_LIST_DIR}/test/default/${test_name}.exp"
            $<TARGET_FILE_DIR:${test_name}>)

        add_test(
            NAME ${test_name}
            COMMAND ${test_name}
            WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>
        )
    endforeach ()
endif ()

install(DIRECTORY src/libsodium/include/
    DESTINATION include/
    USE_SOURCE_PERMISSIONS
    PATTERN "*.h"
    PATTERN "*.h.in" EXCLUDE
    REGEX "private($|/)" EXCLUDE
)

install(FILES ${CMAKE_BINARY_DIR}/sodium/version.h
    DESTINATION include/sodium
)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT ${PROJECT_NAME}-targets
    FILE unofficial-${PROJECT_NAME}Targets.cmake
    NAMESPACE unofficial-${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-${PROJECT_NAME}
)

set(TARGET_NAME unofficial-${PROJECT_NAME}::${PROJECT_NAME})

configure_package_config_file(
    ${PROJECT_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${VERSION}
    COMPATIBILITY AnyNewerVersion
)

unset(TARGET_NAME)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-${PROJECT_NAME}
)

# References:
# https://github.com/boost-cmake/bcm/wiki/Cmake-best-practices-and-guidelines
# https://github.com/jedisct1/libsodium/pull/74/files
# https://github.com/jedisct1/libsodium/pull/156/files
# https://github.com/jedisct1/libsodium/pull/181/files
# https://github.com/jedisct1/libsodium/issues/378
# https://github.com/jedisct1/libsodium/issues/636
# https://github.com/jedisct1/libsodium/issues/771
# https://github.com/jedisct1/libsodium/blob/gyp/sodium.gyp
# https://github.com/imefisto/cmake-libsodium
# https://github.com/Cyberunner23/libsodium-CMake
# https://stackoverflow.com/questions/29901352/appending-to-cmake-c-flags
# https://stackoverflow.com/questions/986426/what-do-stdc-limit-macros-and-stdc-constant-macros-mean
# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
# https://stackoverflow.com/questions/15132185/mixing-c-and-assembly-sources-and-build-with-cmake
# https://stackoverflow.com/questions/647892/how-to-check-header-files-and-library-functions-in-cmake-like-it-is-done-in-auto
# https://stackoverflow.com/questions/31038963/how-do-you-rename-a-library-filename-in-cmake
