cmake_minimum_required(VERSION 3.8.0)
project(butteraugli CXX)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
add_compile_options(-D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018)
endif()

find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)

include_directories(".")

add_library(butteraugli_lib butteraugli/butteraugli.cc)

install(
  TARGETS butteraugli_lib
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  add_executable(butteraugli butteraugli/butteraugli_main.cc)
  target_include_directories(butteraugli PRIVATE ${JPEG_INCLUDE_DIR} ${PNG_INCLUDE_DIRS})
  target_link_libraries(butteraugli PRIVATE butteraugli_lib ${JPEG_LIBRARIES} ${PNG_LIBRARIES})

  install (
    TARGETS butteraugli
    RUNTIME DESTINATION tools/butteraugli
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES butteraugli/butteraugli.h  DESTINATION include/butteraugli)
endif()
