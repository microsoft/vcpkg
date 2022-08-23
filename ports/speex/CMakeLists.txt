cmake_minimum_required(VERSION 3.23.0)

file(STRINGS ${CMAKE_CURRENT_LIST_DIR}/configure.ac config_ac_contents)

foreach (line ${config_ac_contents})
    if (line MATCHES "AC_INIT\\(\\[speex\\],\\[([0-9.]+)\\],")
        set(SPEEX_VERSION ${CMAKE_MATCH_1})
    elseif (line MATCHES "SPEEX_(MAJOR|MINOR|MICRO)_VERSION=([0-9]+)")
        set(SPEEX_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
    endif ()
endforeach ()

project(speex VERSION ${SPEEX_VERSION} LANGUAGES C)

include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckTypeSize)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

option(USE_FIXED_POINT "Compile as fixed-point" OFF)

if(WIN32)
    file(COPY ${PROJECT_SOURCE_DIR}/win32/config.h DESTINATION ${PROJECT_SOURCE_DIR}/libspeex)

    add_compile_definitions(HAVE_CONFIG_H)

    if(USE_FIXED_POINT)
        add_compile_definitions(FIXED_POINT)
    endif()
elseif(UNIX)
    if(NOT APPLE)
        check_include_file(stdint.h HAVE_STDINT_H)
        check_include_file(inttypes.h HAVE_INTTYPES_H)
        check_include_file(sys/types.h HAVE_SYSTYPES_H)

        if (HAVE_STDINT_H)
            set(INCLUDE_STDINT "#include <stdint.h>")
        elseif(HAVE_INTTYPES_H)
            set(INCLUDE_STDINT "#include <inttypes.h>")
        elseif(HAVE_SYSTYPES_H)
            set(INCLUDE_STDINT "#include <sys/types.h>")
        endif()

        check_type_size(int16_t SIZEOF_INT16_T)
        check_type_size(uint16_t SIZEOF_UINT16_T)
        check_type_size(u_int16_t SIZEOF_U_INT16_T)
        check_type_size(int32_t SIZEOF_INT32_T)
        check_type_size(uint32_t SIZEOF_UINT32_T)
        check_type_size(u_int32_t SIZEOF_U_INT32_T)
        check_type_size(short SIZEOF_SHORT)
        check_type_size(int SIZEOF_INT)
        check_type_size(long SIZEOF_LONG)

        if(SIZEOF_INT16_T EQUAL 2)
            set(SIZE16 "int16_t")
        elseif(SIZEOF_SHORT EQUAL 2)
            set(SIZE16 "short")
        elseif(SIZEOF_INT EQUAL 2)
            set(SIZE16 "int")
        endif()
        
        if(SIZEOF_UINT16_T EQUAL 2)
            set(USIZE16 "uint16_t")
        elseif(SIZEOF_U_INT16_T EQUAL 2)
            set(USIZE16 "u_int16_t")
        elseif(SIZEOF_SHORT EQUAL 2)
            set(USIZE16 "unsigned short")
        elseif(SIZEOF_INT EQUAL 2)
            set(USIZE16 "unsigned int")
        endif()

        if(SIZEOF_INT32_T EQUAL 4)
            set(SIZE32 "int32_t")
        elseif(SIZEOF_SHORT EQUAL 4)
            set(SIZE32 "short")
        elseif(SIZEOF_INT EQUAL 4)
            set(SIZE32 "int")
        elseif(SIZEOF_LONG EQUAL 4)
            set(SIZE32 "long")
        endif()
        
        if(SIZEOF_UINT32_T EQUAL 4)
            set(USIZE32 "uint32_t")
        elseif(SIZEOF_U_INT32_T EQUAL 4)
            set(USIZE32 "u_int32_t")
        elseif(SIZEOF_SHORT EQUAL 4)
            set(USIZE32 "unsigned short")
        elseif(SIZEOF_INT EQUAL 4)
            set(USIZE32 "unsigned short")
        elseif(SIZEOF_LONG EQUAL 4)
            set(USIZE32 "unsigned long")
        endif()

        if(NOT SIZE16)
            message(FATAL_ERROR "No 16 bit type found on this platform!")
        endif()

        if(NOT USIZE16)
            message(FATAL_ERROR "No 32 bit type found on this platform!")
        endif()

        if(NOT SIZE32)
            message(FATAL_ERROR "No unsigned 16 bit type found on this platform!")
        endif()

        if(NOT USIZE32)
            message(FATAL_ERROR "No unsigned 32 bit type found on this platform!")
        endif()

        configure_file(
            ${PROJECT_SOURCE_DIR}/include/speex/speex_config_types.h.in
            ${PROJECT_SOURCE_DIR}/include/speex/speex_config_types.h
        )
    endif()

    set(USE_SSE OFF)
    if(NOT USE_FIXED_POINT AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86"))
        set(USE_SSE ON)
    endif()

    if(USE_FIXED_POINT)
        add_compile_definitions(FIXED_POINT)
        add_compile_definitions(USE_KISS_FFT)
    else()
        add_compile_definitions(FLOATING_POINT)
        add_compile_definitions(USE_SMALLFT)
    endif()

    if(USE_SSE)
        add_compile_definitions(_USE_SSE)
    endif()

    check_c_source_compiles(
        "
        #pragma GCC visibility push(hidden)
        __attribute__((visibility(\"default\")))
        int var=10;
        "
        HAVE_VISIBILITY
    )

    if(HAVE_VISIBILITY)
        add_compile_definitions(EXPORT=__attribute__((visibility("default"))))
    else()
        add_compile_definitions(EXPORT=)
    endif()
endif()

if(WIN32)
    file(READ "win32/libspeex.def" _contents)

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libspeex.def"
        "${_contents}\n"
        "speex_nb_mode\n"
        "speex_wb_mode\n"
        "speex_uwb_mode\n"
        "speex_mode_list\n"
        "speex_header_free\n"
    )
endif()

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
)

if (WIN32)
    list(APPEND SRC "${CMAKE_CURRENT_BINARY_DIR}/libspeex.def")
endif()

add_library(${PROJECT_NAME} ${SRC})

target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/libspeex)

file(REMOVE include/Makefile.am)
file(REMOVE include/speex/Makefile.am)
target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if (NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        USE_SOURCE_PERMISSIONS
        PATTERN "*.h"
        PATTERN "*.h.in" EXCLUDE
    )
endif()

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(EXPORT ${PROJECT_NAME}-targets
    FILE unofficial-${PROJECT_NAME}-targets.cmake
    NAMESPACE unofficial::${PROJECT_NAME}::
    DESTINATION share/unofficial-${PROJECT_NAME}
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/unofficial-speex-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-speex-config.cmake
    INSTALL_DESTINATION share/unofficial-${PROJECT_NAME}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config-version.cmake
    VERSION ${VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config-version.cmake
    DESTINATION share/unofficial-${PROJECT_NAME}
)

# pkgconfig file
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})

set(LIBM)
check_library_exists(m ceil "" LIBMEXIST)
if(LIBMEXIST)
    list(APPEND LIBM -lm)
endif()

configure_file(speex.pc.in speex.pc @ONLY)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/speex.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
