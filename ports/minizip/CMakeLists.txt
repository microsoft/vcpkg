cmake_minimum_required(VERSION 3.25)
project(minizip LANGUAGES C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(SRC
  ioapi.c
  unzip.c
  zip.c
  mztools.c
)
set(HEADERS
  crypt.h
  ioapi.h
  unzip.h
  zip.h
  mztools.h
)
if(WIN32)
  list(APPEND SRC iowin32.c)
  list(APPEND HEADERS iowin32.h)
endif()

add_library(minizip ${SRC})
target_include_directories(minizip PUBLIC $<INSTALL_INTERFACE:include/minizip>)

find_package(ZLIB REQUIRED)
target_compile_definitions(minizip PRIVATE -D_ZLIB_H)
target_link_libraries(minizip PUBLIC ZLIB::ZLIB)
set(MINIZIP_REQUIRES zlib)

if(ENABLE_BZIP2)
  message(STATUS "Building with bzip2 support")
  find_package(BZip2 REQUIRED)
  target_compile_definitions(minizip PRIVATE -DHAVE_BZIP2=1)
  target_link_libraries(minizip PUBLIC BZip2::BZip2)
  list(APPEND MINIZIP_REQUIRES bzip2)
else()
  message(STATUS "Building without bzip2 support")
endif()

if(ANDROID)
  target_compile_definitions(minizip PRIVATE IOAPI_NO_64)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  target_compile_definitions(minizip PRIVATE -DIOWIN32_USING_WINRT_API)
endif()

if(NOT DISABLE_INSTALL_TOOLS)
  add_executable(minizip_bin minizip.c)
  add_executable(miniunz_bin miniunz.c)

  target_link_libraries(minizip_bin minizip)
  target_link_libraries(miniunz_bin minizip)

  set_target_properties(minizip_bin PROPERTIES OUTPUT_NAME minizip)
  set_target_properties(miniunz_bin PROPERTIES OUTPUT_NAME miniunz)

  install (
    TARGETS minizip_bin miniunz_bin
    RUNTIME DESTINATION bin
  )
endif()

install(
  TARGETS minizip
  EXPORT unofficial-minizipTargets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file("${PROJECT_BINARY_DIR}/unofficial-minizipConfigVersion.cmake"
  VERSION "${PACKAGE_VERSION}"
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(unofficial-minizipConfig.cmake.in
  unofficial-minizipConfig.cmake
  INSTALL_DESTINATION share/unofficial-minizip
)

install(FILES
        "${PROJECT_BINARY_DIR}/unofficial-minizipConfig.cmake"
        "${PROJECT_BINARY_DIR}/unofficial-minizipConfigVersion.cmake"
        DESTINATION share/unofficial-minizip
)

install(EXPORT unofficial-minizipTargets
        NAMESPACE unofficial::minizip::
        DESTINATION share/unofficial-minizip
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${HEADERS} DESTINATION include/minizip)
endif()

list(JOIN MINIZIP_REQUIRES " " MINIZIP_REQUIRES)
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/minizip.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/minizip.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/minizip.pc"
    DESTINATION lib/pkgconfig
)

