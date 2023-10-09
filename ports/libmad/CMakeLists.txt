cmake_minimum_required(VERSION 2.8)

project(libmad)

set(SOURCES
    bit.c
    bit.h
    config.h
    decoder.c
    decoder.h
    fixed.c
    fixed.h
    frame.c
    frame.h
    global.h
    huffman.c
    huffman.h
    layer12.c
    layer12.h
    layer3.c
    layer3.h
    mad.h
    stream.c
    stream.h
    synth.c
    synth.h
    timer.c
    timer.h
    version.c
    version.h
)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/mad.pc.in" "${PROJECT_BINARY_DIR}/mad.pc" @ONLY)
install(
    FILES "${PROJECT_BINARY_DIR}/mad.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
add_library(
    mad
    ${SOURCES}
)

target_compile_definitions(mad
    PRIVATE _LIB _MBCS ASO_ZEROCHECK HAVE_CONFIG_H
    PRIVATE _CRT_SECURE_NO_WARNINGS
)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "(^i.86$)")
    target_compile_definitions(mad
        PRIVATE FPM_INTEL
    )
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86_64)|(AMD64|amd64)|^(aarch64|arm64)")
    target_compile_definitions(mad
        PRIVATE FPM_64BIT
    )
# This fails with "error: invalid instruction" on armv7-a 
#elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
#    target_compile_definitions(mad
#        PRIVATE FPM_ARM
#    )
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^mips")
    target_compile_definitions(mad
        PRIVATE FPM_MIPS
    )
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)")
    target_compile_definitions(mad
        PRIVATE FPM_PPC
    )
else()
    target_compile_definitions(mad
        PRIVATE FPM_DEFAULT
    )
    message(WARNING "CMAKE_SYSTEM_PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR} unknown. Fall back to FPM_DEFAULT, loosing significant accuracy")
endif()

install(
    TARGETS mad
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    FILES mad.h
    DESTINATION include
)
