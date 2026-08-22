cmake_minimum_required(VERSION 3.13)

option(CMAKE_VERBOSE_MAKEFILE "Create verbose makefile" OFF)
option(BUILD_SHARED_LIBS "Create duktape as a shared library" ON)

project(duktape VERSION ${VERSION})

file(GLOB_RECURSE DUKTAPE_SOURCES "${CMAKE_CURRENT_LIST_DIR}/src/*.c")
file(GLOB_RECURSE DUKTAPE_HEADERS "${CMAKE_CURRENT_LIST_DIR}/src/*.h")

add_library(duktape ${DUKTAPE_SOURCES} ${DUKTAPE_HEADERS})
target_include_directories(duktape PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")
target_include_directories(duktape PUBLIC "$<INSTALL_INTERFACE:include>")
set_target_properties(duktape PROPERTIES PUBLIC_HEADER "${DUKTAPE_HEADERS}")
set_target_properties(duktape PROPERTIES VERSION ${duktape_VERSION})
set_target_properties(duktape PROPERTIES SOVERSION ${duktape_VERSION_MAJOR})

if (BUILD_SHARED_LIBS)
  target_compile_definitions(duktape PRIVATE -DDUK_F_DLL_BUILD)
endif ()

install(TARGETS duktape
        EXPORT duktapeTargets
        ARCHIVE DESTINATION "lib"
        LIBRARY DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include"
        COMPONENT dev
)

install(EXPORT duktapeTargets
  FILE unofficial-duktape-config.cmake
  NAMESPACE unofficial::duktape::
  DESTINATION "share/unofficial-duktape"
)

export(PACKAGE duktape)

include(CMakePackageConfigHelpers)
write_basic_package_version_file("${PROJECT_BINARY_DIR}/unofficial-duktape-config-version.cmake"
  COMPATIBILITY SameMajorVersion
)

install(FILES
  "${PROJECT_BINARY_DIR}/unofficial-duktape-config-version.cmake"
  DESTINATION "share/unofficial-duktape"
)

set(prefix "")
set(LIBDIR "/lib")
set(VERSION "${duktape_VERSION}")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/duktape.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/duktape.pc" @ONLY)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/duktape.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
