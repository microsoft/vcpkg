cmake_minimum_required(VERSION 3.8.0)
project(scylla_wrapper CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 /DUNICODE /D_UNICODE -D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
endif()

find_library(DISTORM_LIBRARY distorm)
find_path(DISTORM_INCLUDE_DIR distorm.h)

include_directories(scylla_wrapper ${DISTORM_INCLUDE_DIR})

file(GLOB scylla_wrapper_srcs "scylla_wrapper/*.cpp")

add_library(scylla_wrapper ${scylla_wrapper_srcs})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(scylla_wrapper PRIVATE -DSCYLLA_WRAPPER_EXPORTS)
endif()

target_link_libraries(scylla_wrapper PRIVATE ${DISTORM_LIBRARY})

install(
  TARGETS scylla_wrapper
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES scylla_wrapper/scylla_wrapper.h  DESTINATION include)
endif()
