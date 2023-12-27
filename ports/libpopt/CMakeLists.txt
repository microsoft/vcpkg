cmake_minimum_required(VERSION 3.0)
project(popt VERSION 1.16 LANGUAGES C)

set(PACKAGE "popt")
set(POPT_SYSCONFDIR "C:\\\\")
set(CMAKE_DEBUG_POSTFIX "d")

file(GLOB SOURCES "popt.c"
                  "poptconfig.c"
                  "popthelp.c"
                  "poptint.c"
                  "poptparse.c"
                  "popt.def"
)

option(POPT_USE_CONFIG "Use configuration file" OFF)

if(POPT_USE_CONFIG)
  include(CheckIncludeFile)
  include(CheckFunctionExists)

  if(ANDROID AND ANDROID_NATIVE_API_LEVEL LESS "28")
    set(HAVE_GLOB_H FALSE CACHE INTERNAL "")
  endif()

  check_include_file(float.h HAVE_FLOAT_H)
  check_include_file(fnmatch.h HAVE_FNMATCH_H)
  check_include_file(glob.h HAVE_GLOB_H)
  check_include_file(langinfo.h HAVE_LANGINFO_H)
  check_include_file(libintl.h HAVE_LIBINTL_H)
  check_include_file(mcheck.h HAVE_MCHECK_H)
  check_include_file(unistd.h HAVE_UNISTD_H)


  check_function_exists(gettext HAVE_GETTEXT)
  check_function_exists(iconv HAVE_ICONV)
  check_function_exists(mtrace HAVE_MTRACE)
  check_function_exists(srandom HAVE_SRANDOM)
  check_function_exists(stpcpy HAVE_STPCPY)
  check_function_exists(strerror HAVE_STRERROR)
  check_function_exists(vasprintf HAVE_VASPRINTF)
  check_function_exists(__secure_getenv HAVE___SECURE_GETENV)

  configure_file(config.h.cmake config.h @ONLY)
  add_definitions(-DHAVE_CONFIG_H)
endif()

add_definitions(-D_CRT_SECURE_NO_WARNINGS)

include_directories(${CMAKE_BINARY_DIR})

add_library(popt ${SOURCES})
if (MSVC)
    target_compile_options(popt PRIVATE /wd4996)
endif()

install(TARGETS popt
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(FILES "popt.h" DESTINATION "include")