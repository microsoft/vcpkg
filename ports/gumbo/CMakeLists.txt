cmake_minimum_required(VERSION 3.16.0)

project(gumbo LANGUAGES C)

set(gumbo_public_headers
    src/gumbo.h
    src/tag_enum.h
)

set(gumbo_srcs
    src/attribute.c
    src/char_ref.c
    src/error.c
    src/parser.c
    src/string_buffer.c
    src/string_piece.c
    src/tag.c
    src/tokenizer.c
    src/utf8.c
    src/util.c
    src/vector.c
    src/char_ref_gperf.c
)

add_library(gumbo ${gumbo_srcs})

set_target_properties(gumbo PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
    C_EXTENSIONS OFF
    PUBLIC_HEADER "${gumbo_public_headers}"
)

# More readable than:
# $<BUILD_INTERFACE:$<$<OR:$<C_COMPILER_ID:MSVC>,$<STREQUAL:$<CMAKE_C_COMPILER_FRONTEND_VARIANT>,MSVC>>:${CMAKE_CURRENT_SOURCE_DIR}/visualc/include>>
if(MSVC)
    set(VISUALC_INCLUDE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/visualc/include>")
else()
    set(VISUALC_INCLUDE "")
endif()

target_include_directories(gumbo PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    ${VISUALC_INCLUDE}
    $<INSTALL_INTERFACE:include/>
)

install(
    TARGETS gumbo  EXPORT unofficial-gumbo-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)

install(EXPORT unofficial-gumbo-config
    NAMESPACE unofficial::gumbo::
    DESTINATION share/unofficial-gumbo
)

set(prefix "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/gumbo.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc"
    @ONLY
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc" DESTINATION "lib/pkgconfig")

