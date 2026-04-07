cmake_minimum_required(VERSION 3.8.0)
project(guetzli)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
endif()

find_path(butteraugli_include butteraugli/butteraugli.h)
find_library(butteraugli_library NAMES butteraugli_lib)
find_package(PNG REQUIRED)

include_directories("."  ${PNG_INCLUDE_DIRS} ${butteraugli_include})

file(GLOB guetzli_srcs "guetzli/*.cc")
file(GLOB guetzli_includes "guetzli/*.h")
list(REMOVE_ITEM guetzli_srcs "guetzli/guetzli.cc")

add_library(guetzli_lib ${guetzli_srcs})

target_compile_features(guetzli_lib PUBLIC cxx_std_11)

add_executable(guetzli guetzli/guetzli.cc)

target_link_libraries(guetzli_lib ${butteraugli_library} ${PNG_LIBRARIES})
target_link_libraries(guetzli guetzli_lib ${butteraugli_library} ${PNG_LIBRARIES})


install(
  TARGETS guetzli_lib
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS guetzli
    RUNTIME DESTINATION tools/guetzli
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${guetzli_includes}  DESTINATION include/guetzli)
endif()
