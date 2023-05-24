cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(nana VERSION 1.7.4 LANGUAGES CXX)

option(NANA_ENABLE_PNG "Enable PNG support" OFF)
option(NANA_ENABLE_JPEG "Enable JPEG support" OFF)
option(NANA_INSTALL_HEADERS "Install headers" ON)

if(APPLE)
  add_definitions(-DAPPLE)
elseif(UNIX)
  add_definitions(-Dlinux)
endif()

file(GLOB_RECURSE headers include/*.hpp)
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/include PREFIX "include" FILES ${headers})

file(GLOB sources source/*.hpp source/*.cpp)
foreach(subdir detail filesystem gui paint system threads)
  file(GLOB_RECURSE sources_subdir source/${subdir}/*.hpp source/${subdir}/*.cpp)
  list(APPEND sources ${sources_subdir})
endforeach()
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/source PREFIX "source" FILES ${sources})

add_library(nana ${headers} ${sources})
target_include_directories(nana PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)

target_compile_features(nana PUBLIC cxx_std_17)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_link_libraries(nana PUBLIC c++experimental)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GCC")
  target_link_libraries(nana PUBLIC stdc++fs)
endif()

if(UNIX)
  find_package(Threads REQUIRED)
  target_link_libraries(nana PUBLIC Threads::Threads)

  find_package(Freetype REQUIRED)
  target_link_libraries(nana PUBLIC Freetype::Freetype)

  find_package(X11 REQUIRED)
  target_include_directories(nana PUBLIC ${X11_INCLUDE_DIR})
  target_link_libraries(nana PUBLIC ${X11_LIBRARIES} ${X11_Xft_LIB})

  find_package(Fontconfig REQUIRED)
  target_link_libraries(nana PUBLIC Fontconfig::Fontconfig)
endif()

if(NANA_ENABLE_PNG)
  find_package(PNG REQUIRED)
  target_link_libraries(nana PUBLIC PNG::PNG)
  target_compile_definitions(nana PUBLIC NANA_ENABLE_PNG=1 USE_LIBPNG_FROM_OS=1)
endif()

if(NANA_ENABLE_JPEG)
  find_package(JPEG REQUIRED)
  target_include_directories(nana PUBLIC ${JPEG_INCLUDE_DIR})
  target_link_libraries(nana PUBLIC $<BUILD_INTERFACE:${JPEG_LIBRARIES}>)
  target_compile_definitions(nana PUBLIC NANA_ENABLE_JPEG=1 USE_LIBJPEG_FROM_OS=1)
endif()

install(TARGETS nana EXPORT nana
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

if(NANA_INSTALL_HEADERS)
  install(DIRECTORY include/nana DESTINATION include)
endif()

include(CMakePackageConfigHelpers)

configure_package_config_file(config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/unofficial-nana-config.cmake
  INSTALL_DESTINATION share/unofficial-nana)

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/unofficial-nana-config-version.cmake
  VERSION ${PROJECT_VERSION} COMPATIBILITY SameMajorVersion)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-nana-config.cmake DESTINATION share/unofficial-nana)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-nana-config-version.cmake DESTINATION share/unofficial-nana)
install(EXPORT nana FILE unofficial-nana-targets.cmake NAMESPACE unofficial::nana:: DESTINATION share/unofficial-nana)
