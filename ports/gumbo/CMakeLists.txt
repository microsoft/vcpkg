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
  TARGETS gumbo  EXPORT unofficial-gumboTargets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-gumboTargets
    NAMESPACE unofficial::gumbo::
    DESTINATION share/unofficial-gumbo
    )

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-gumbo-config.cmake.in"
[[
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-gumboTargets.cmake")
]])

configure_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-gumbo-config.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-gumbo-config.cmake" @ONLY)
configure_file("${SOURCE_PATH}/gumbo.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gumbo.pc" @ONLY)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-gumbo-config.cmake DESTINATION unofficial-gumbo)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES  src/gumbo.h src/tag_enum.h DESTINATION include)
endif()
