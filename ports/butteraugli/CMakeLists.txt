cmake_minimum_required(VERSION 3.8.0)
project(butteraugli CXX)

add_compile_options(-D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018)
else()
  add_compile_options(-std=c++11)
endif()

find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)

include_directories("."  ${JPEG_INCLUDE_DIR} ${PNG_INCLUDE_DIRS})

add_library(butteraugli_lib butteraugli/butteraugli.cc)

install(
  TARGETS butteraugli_lib
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  add_executable(butteraugli butteraugli/butteraugli_main.cc)
  find_library(TURBO turbojpeg)
  target_link_libraries(butteraugli butteraugli_lib ${JPEG_LIBRARIES} ${TURBO} ${PNG_LIBRARIES})

  install (
    TARGETS butteraugli
    RUNTIME DESTINATION tools/butteraugli
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES butteraugli/butteraugli.h  DESTINATION include/butteraugli)
endif()
