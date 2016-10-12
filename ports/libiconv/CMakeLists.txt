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
  ${Libiconv_SOURCE_DIR}/config.h.in
  ${Libiconv_BINARY_DIR}/config.h
)

set(HAVE_WCHAR_T "1 /*HAVE_WCHAR_T*/")
set(USE_MBSTATE_T "0 /*USE_MBSTATE_T*/")
set(BROKEN_WCHAR_H "0 /*BROKEN_WCHAR_H*/")
set(HAVE_VISIBILITY "0 /*HAVE_VISIBILITY*/")

include_directories(${Libiconv_SOURCE_DIR} ${Libiconv_BINARY_DIR})

#
# Build libcharset
#
set(libname libcharset)
set(libcharset_source_dir ${Libiconv_SOURCE_DIR}/libcharset)

add_definitions(-DLIBDIR)
  
configure_file(
  ${Libiconv_SOURCE_DIR}/libcharset/include/localcharset.h.build.in
  ${Libiconv_BINARY_DIR}/localcharset.h
)

set(${libname}_sources
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

configure_file(
  ${Libiconv_SOURCE_DIR}/include/iconv.h.build.in
  ${Libiconv_BINARY_DIR}/iconv.h
  )

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
