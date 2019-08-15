cmake_minimum_required(VERSION 3.0.0)
project(libiconv C)

if(BUILD_SHARED_LIBS)
  set(LIBICONV_DYNAMIC "1 /*LIBICONV_DYNAMIC*/")
else()
  set(LIBICONV_DYNAMIC "0 /*LIBICONV_DYNAMIC*/")
endif()

set(CMAKE_STATIC_LIBRARY_PREFIX)
set(CMAKE_SHARED_LIBRARY_PREFIX)

if(WIN32)
  set(HAVE_WCHAR_T "1 /*HAVE_WCHAR_T*/")
  set(USE_MBSTATE_T "0 /*USE_MBSTATE_T*/")
  set(BROKEN_WCHAR_H "0 /*BROKEN_WCHAR_H*/")
  set(HAVE_VISIBILITY "0 /*HAVE_VISIBILITY*/")

  configure_file(config.h.in config.h)
  file(READ "${CMAKE_CURRENT_BINARY_DIR}/config.h" _contents)
  string(REPLACE "#undef HAVE_WORKING_O_NOFOLLOW" "#define HAVE_WORKING_O_NOFOLLOW 0" _contents "${_contents}")
  string(REPLACE "#undef HAVE_MBRTOWC" "#define HAVE_MBRTOWC 1" _contents "${_contents}")
  string(REPLACE "#undef HAVE_MBSINIT" "#define HAVE_MBSINIT 1" _contents "${_contents}")
  string(REPLACE "#undef HAVE_WCRTOMB" "#define HAVE_WCRTOMB 1" _contents "${_contents}")
  string(REPLACE "#undef ICONV_CONST" "#define ICONV_CONST const" _contents "${_contents}")
  string(REPLACE "#undef EILSEQ" "" _contents "${_contents}")
  string(REPLACE "#undef WORDS_LITTLEENDIAN" "#define WORDS_LITTLEENDIAN 1" _contents "${_contents}")
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/config.h" "${_contents}")

  configure_file(libcharset/include/localcharset.h.build.in localcharset.h)
  configure_file(include/iconv.h.build.in iconv.h)
else()
  if(BUILD_SHARED_LIBS)
    set(STATIC_SHARED --enable-shared --disable-static)
  else()
    set(STATIC_SHARED --disable-shared --enable-static)
  endif()

  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/autoconf)

  execute_process(
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/configure --enable-relocatable ${STATIC_SHARED} --without-libiconv-prefix --without-libintl-prefix
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/autoconf
  )

  configure_file(${CMAKE_CURRENT_BINARY_DIR}/autoconf/config.h config.h @ONLY)
  configure_file(${CMAKE_CURRENT_BINARY_DIR}/autoconf/include/iconv.h iconv.h @ONLY)
  configure_file(${CMAKE_CURRENT_BINARY_DIR}/autoconf/libcharset/include/localcharset.h localcharset.h @ONLY)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

add_definitions(-DLIBDIR -D_CRT_SECURE_NO_WARNINGS)

add_library(libcharset libcharset/lib/localcharset.c)
target_include_directories(libcharset PUBLIC $<INSTALL_INTERFACE:include>)

add_library(libiconv lib/iconv.c)
target_link_libraries(libiconv PRIVATE libcharset)
target_include_directories(libiconv PUBLIC $<INSTALL_INTERFACE:include>)

install(TARGETS libcharset libiconv EXPORT unofficial-iconv-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/iconv.h
    ${CMAKE_CURRENT_BINARY_DIR}/localcharset.h
    DESTINATION include
  )
endif()

install(
    EXPORT unofficial-iconv-targets
    FILE unofficial-iconv-config.cmake
    NAMESPACE unofficial::iconv::
    DESTINATION share/unofficial-iconv
)