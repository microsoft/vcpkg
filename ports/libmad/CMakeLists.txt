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
    PRIVATE _LIB _MBCS ASO_ZEROCHECK HAVE_CONFIG_H FPM_DEFAULT
    PRIVATE _CRT_SECURE_NO_WARNINGS
)

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
