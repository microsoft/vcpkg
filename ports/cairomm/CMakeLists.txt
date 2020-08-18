project(cairomm)
cmake_minimum_required(VERSION 3.4)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/build/cmake")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#get cairomm version
file (STRINGS "configure.ac" CONFIGURE_AC_INIT REGEX "AC_INIT\\(\\[cairomm\\], \\[.*\\].*" )
string(REGEX REPLACE "AC_INIT\\(\\[.*\\], \\[([0-9]+\\.[0-9]+\\.[0-9]+)\\].*" "\\1"  VERSION ${CONFIGURE_AC_INIT})
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" CAIROMM_MAJOR_VERSION ${VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\.[0-9]+" "\\1" CAIROMM_MINOR_VERSION ${VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" CAIROMM_MICRO_VERSION ${VERSION})
message(STATUS "Ciaromm version: ${CAIROMM_MAJOR_VERSION}.${CAIROMM_MINOR_VERSION}.${CAIROMM_MICRO_VERSION}")

find_package(Cairo REQUIRED)
find_package(SigC++ REQUIRED)

#configure
option(BUILD_SHARED_LIBS "Build the shared library" ON)

option(CAIROMM_ENABLE_API_EXCEPTIONS "enable API exceptions" ON)
if(CAIROMM_ENABLE_API_EXCEPTIONS)
    set(CAIROMM_EXCEPTIONS_ENABLED ON)
else()
    set(CAIROMM_EXCEPTIONS_ENABLED OFF)
endif()

configure_file("build/cmake/cairommconfig.h.cmake" "cairommconfig.h")
configure_file("build/cmake/cairomm.rc.cmake" "cairomm.rc" @ONLY)

#build
set(cairomm_cc
    cairomm/context.cc
    cairomm/context_surface_quartz.cc
    cairomm/context_surface_win32.cc
    cairomm/context_surface_xlib.cc
    cairomm/device.cc
    cairomm/exception.cc
    cairomm/fontface.cc
    cairomm/fontoptions.cc
    cairomm/matrix.cc
    cairomm/path.cc
    cairomm/pattern.cc
    cairomm/private.cc
    cairomm/quartz_font.cc
    cairomm/quartz_surface.cc
    cairomm/region.cc
    cairomm/scaledfont.cc
    cairomm/script.cc
    cairomm/script_surface.cc
    cairomm/surface.cc
    cairomm/win32_font.cc
    cairomm/win32_surface.cc
    cairomm/xlib_surface.cc)

set(cairomm_public_h
    cairomm/cairomm.h
    cairomm/context.h
    cairomm/device.h
    cairomm/enums.h
    cairomm/exception.h
    cairomm/fontface.h
    cairomm/fontoptions.h
    cairomm/matrix.h
    cairomm/path.h
    cairomm/pattern.h
    cairomm/quartz_font.h
    cairomm/quartz_surface.h
    cairomm/refptr.h
    cairomm/region.h
    cairomm/scaledfont.h
    cairomm/script.h
    cairomm/script_surface.h
    cairomm/surface.h
    cairomm/types.h
    cairomm/win32_font.h
    cairomm/win32_surface.h
    cairomm/xlib_surface.h)

set(cairomm_private_h
    cairomm/context_private.h
    cairomm/private.h)

set(cairomm_rc
    ${CMAKE_BINARY_DIR}/cairomm.rc)

add_library(cairomm-1.0 ${cairomm_cc} ${cairomm_rc})
target_link_libraries(cairomm-1.0 ${CAIRO_LIBRARY} ${SIGC++_LIBRARY} )
target_include_directories(cairomm-1.0 PRIVATE
    ${CAIRO_INCLUDE_DIR}
    ${SIGC++_INCLUDE_DIR}
    ${CMAKE_BINARY_DIR}
    ${CMAKE_SOURCE_DIR})

install(
    TARGETS cairomm-1.0
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(
    FILES ${cairomm_public_h}
    DESTINATION include/cairomm)

install(
    FILES ${CMAKE_BINARY_DIR}/cairommconfig.h
    DESTINATION include)
