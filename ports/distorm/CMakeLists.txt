cmake_minimum_required(VERSION 3.8.0)
project(distorm C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
endif()

if(UNIX)
  add_compile_options(-DSUPPORT_64BIT_OFFSET)
endif()


 set(
 distorm_srcs
 src/decoder.c
    src/distorm.c
    src/instructions.c
    src/insts.c
    src/mnemonics.c
    src/operands.c
    src/prefix.c
    src/textdefs.c
    src/wstring.c
  )


include_directories(include src)

add_library(distorm ${distorm_srcs})


if(BUILD_SHARED_LIBS)
  target_compile_definitions(distorm PRIVATE -DDISTORM_DYNAMIC=1 -DSUPPORT_64BIT_OFFSET=1)
else()
  target_compile_definitions(distorm PRIVATE -DDISTORM_STATIC=1 -DSUPPORT_64BIT_OFFSET=1)
endif()

install(
  TARGETS distorm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/distorm.h  DESTINATION include)
endif()
