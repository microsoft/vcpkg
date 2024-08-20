cmake_minimum_required(VERSION 3.25)
project(mujs C)

set(LINK_LIBRARIES "")
set(PC_LIBS_PRIVATE "")

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
else()
  find_library(HAVE_LIBM NAMES m)
  if(HAVE_LIBM)
    list(APPEND LINK_LIBRARIES m)
    string(APPEND PC_LIBS_PRIVATE " -lm")
  endif()
endif()

file(GLOB mujs_sources js*.c utf*.c regexp.c)

add_library(mujs ${mujs_sources})

target_include_directories(mujs
  PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:include>"
)

target_link_libraries(mujs PRIVATE ${LINK_LIBRARIES})

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

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/mujs.pc" "${CMAKE_CURRENT_BINARY_DIR}/mujs.pc" @ONLY)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/mujs.pc"
  DESTINATION "lib/pkgconfig"
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES mujs.h DESTINATION include)
endif()
