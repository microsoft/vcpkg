cmake_minimum_required(VERSION 3.8.0)

project(gumbo)

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
)

include_directories(src)
if (MSVC)
  include_directories(visualc/include)
endif (MSVC)

add_library(gumbo ${gumbo_srcs})

set_target_properties(gumbo PROPERTIES
    C_STANDARD 99
    PUBLIC_HEADER "${gumbo_public_headers}"
)

target_include_directories(gumbo PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/>)

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
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/gumbo.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc" @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc" DESTINATION "lib/pkgconfig")

