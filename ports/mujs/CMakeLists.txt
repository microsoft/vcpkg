cmake_minimum_required(VERSION 3.25)
project(mujs C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

file(GLOB mujs_sources js*.c utf*.c regexp.c)

add_library(mujs ${mujs_sources})

target_include_directories(mujs
  PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:include>"
)

install(
  TARGETS mujs
  EXPORT unofficial-mujs-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(
  EXPORT unofficial-mujs-targets
  FILE unofficial-mujs-config.cmake
  NAMESPACE unofficial::mujs::
  DESTINATION "share/unofficial-mujs"
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(unofficial-mujs-config-version.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-mujs-config-version.cmake"
  DESTINATION "share/unofficial-mujs"
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES mujs.h DESTINATION include)
endif()
