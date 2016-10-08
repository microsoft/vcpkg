##
## CMake support for libiconv
## based on the work here: https://github.com/vovythevov/libiconv-cmake
##

cmake_minimum_required(VERSION 3.0.0)
project(Libiconv)

#
# Options
#
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries, Always ON since this code is LGPL" FORCE)

# Config file
configure_file(
  ${Libiconv_SOURCE_DIR}/new_config.h.in
  ${Libiconv_BINARY_DIR}/config.h
)
include_directories(${Libiconv_SOURCE_DIR} ${Libiconv_BINARY_DIR})

macro(header_injection_hack)
  include(CMakeParseArguments)
  set(options)
  set(oneValueArgs LIBRARY_NAME INPUT OUTPUT)
  set(multiValueArgs)
  cmake_parse_arguments(hack
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN}
  )
  string(TOUPPER ${hack_LIBRARY_NAME} hack_library_name_upper)
  set(HAVE_VISIBILITY
  "WIN32
    #if defined(${hack_LIBRARY_NAME}_EXPORTS)
      #define ${hack_library_name_upper}_DLL_EXPORTED __declspec(dllexport)
    #else
      #define ${hack_library_name_upper}_DLL_EXPORTED __declspec(dllimport)
    #endif
  #elif true"
  )
  configure_file(
    ${hack_INPUT}
    ${hack_OUTPUT}
    )
endmacro()
#
# Build libcharset
#
set(libname libcharset)
set(libcharset_source_dir ${Libiconv_SOURCE_DIR}/libcharset)

if(WIN32)
  add_definitions(-DLIBDIR)
endif()

# Hack: to be able to configure the localcharset.h.build.in correctly, we
# inject code in the variable have visibility
header_injection_hack(
  LIBRARY_NAME ${libname}
  INPUT ${Libiconv_SOURCE_DIR}/libcharset/include/localcharset.h.build.in
  OUTPUT ${Libiconv_BINARY_DIR}/localcharset.h
  )

set(${libname}_sources
  ${libcharset_source_dir}/lib/relocatable.c
  ${libcharset_source_dir}/lib/relocatable.h
  ${libcharset_source_dir}/lib/localcharset.c
  ${Libiconv_BINARY_DIR}/localcharset.h
)

add_library(${libname} ${${libname}_sources})
list(APPEND Libiconv_TARGETS ${libname})
list(APPEND Libiconv_headers ${Libiconv_BINARY_DIR}/localcharset.h)

#
# Build libiconv
#
set(libname libiconv)

# Hack: same hack than for libcharset
set(HAVE_WCHAR_T "HAVE_WCHAR_T")
set(USE_MBSTATE_T "USE_MBSTATE_T")
set(BROKEN_WCHAR_H "BROKEN_WCHAR_H")

header_injection_hack(
  LIBRARY_NAME ${libname}
  INPUT ${Libiconv_SOURCE_DIR}/include/iconv.h.build.in
  OUTPUT ${Libiconv_BINARY_DIR}/iconv.h
  )

list(APPEND simple_header_config
  uniwidth
  unitypes
  )
foreach(header ${simple_header_config})
  configure_file(
    ${Libiconv_SOURCE_DIR}/srclib/${header}.in.h
    ${Libiconv_BINARY_DIR}/${header}.h
    )
endforeach()

set(${libname}_sources
  ${Libiconv_SOURCE_DIR}/lib/iconv.c
  ${Libiconv_BINARY_DIR}/iconv.h
)

add_library(${libname} ${${libname}_sources})
target_link_libraries(${libname} libcharset)
list(APPEND Libiconv_TARGETS ${libname})
list(APPEND Libiconv_headers ${Libiconv_BINARY_DIR}/iconv.h)

#
# Export targets
#
install(TARGETS ${Libiconv_TARGETS}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(FILES ${Libiconv_headers} DESTINATION include)

set(Libiconv_TARGETS_FILE ${Libiconv_BINARY_DIR}/LibiconvTargets.cmake)
export(TARGETS ${Libiconv_TARGETS} FILE ${Libiconv_TARGETS_FILE})

configure_file(
  ${Libiconv_SOURCE_DIR}/LibiconvConfig.cmake.in
  ${Libiconv_BINARY_DIR}/LibiconvConfig.cmake
  @ONLY
)
