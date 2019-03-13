cmake_minimum_required(VERSION 3.8.0)

project(libunibreak)

set(libunibreak_srcs
  src/linebreakdata.c
  src/linebreakdef.c
  src/linebreak.c
  src/wordbreak.c
  src/graphemebreak.c
  src/unibreakbase.c
  src/unibreakdef.c
)


include_directories(src)

add_library(libunibreak ${libunibreak_srcs})

install(
  TARGETS libunibreak
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES
    src/linebreak.h
    src/linebreakdef.h
    src/wordbreak.h
    src/wordbreakdef.h
    src/unibreakbase.h
    src/unibreakdef.h
    DESTINATION include
  )
endif()
