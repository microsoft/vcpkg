cmake_minimum_required(VERSION 3.8.0)

project(libunibreak)

set(libunibreak_srcs
  src/linebreak.c
  src/linebreakdata.c
  src/linebreakdef.c
  src/wordbreak.c
  src/graphemebreak.c
  src/emojidef.c
  src/eastasianwidthdef.c
  src/unibreakbase.c
  src/unibreakdef.c
)

include_directories(src)

add_library(unibreak ${libunibreak_srcs})

install(
  TARGETS unibreak
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES
    src/emojidef.h
    src/eastasianwidthdef.h
    src/unibreakbase.h
    src/unibreakdef.h
    src/graphemebreak.h
    src/graphemebreakdef.h
    src/linebreak.h
    src/linebreakdef.h
    src/test_skips.h
    src/wordbreak.h
    src/wordbreakdef.h
    DESTINATION include
  )
endif()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libunibreak.pc"
"prefix=${CMAKE_INSTALL_PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libunibreak
Description: Library to implement Unicode algorithms for line and word breaking
Version: ${UNIBREAK_VERSION}
Libs: -L\${libdir} -lunibreak
Cflags: -I\${includedir}
")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libunibreak.pc" DESTINATION lib/pkgconfig)
