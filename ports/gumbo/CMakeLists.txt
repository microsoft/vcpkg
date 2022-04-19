cmake_minimum_required(VERSION 3.8.0)

project(gumbo)

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

install(
  TARGETS gumbo  EXPORT unofficial-gumbo-config
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-gumbo-config
    NAMESPACE unofficial::gumbo::
    DESTINATION share/unofficial-gumbo
    )
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/gumbo.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc" @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/lib/pkgconfig/gumbo.pc" DESTINATION "lib/pkgconfig")
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES  src/gumbo.h src/tag_enum.h DESTINATION include)
endif()
