cmake_minimum_required(VERSION 3.5)
project(libintl C)

find_library(ICONV_LIB NAMES iconv libiconv)
find_path(ICONV_PATH iconv.h)

find_library(CHARSET_LIB NAMES charset libcharset)
find_path(CHARSET_PATH localcharset.h)

include_directories(${CMAKE_CURRENT_BINARY_DIR} . ${ICONV_PATH} ${CHARSET_PATH})
link_libraries(${CHARSET_LIB} ${ICONV_LIB})

file(READ config.h _contents)
if(NOT WIN32)
    string(REPLACE "/* #undef HAVE_STPCPY */" "#define HAVE_STPCPY 1" _contents "${_contents}")
endif()
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/config.h" "${_contents}")

FILE(GLOB SOURCES
"intl/bindtextdom.c"
"intl/dcgettext.c"
"intl/dcigettext.c"
"intl/dcngettext.c"
"intl/dgettext.c"
"intl/dngettext.c"
"intl/explodename.c"
"intl/finddomain.c"
"intl/gettext.c"
"intl/hash-string.c"
"intl/intl-compat.c"
"intl/l10nflist.c"
"intl/langprefs.c"
"intl/loadmsgcat.c"
"intl/localealias.c"
"intl/localename.c"
"intl/lock.c"
"intl/log.c"
"intl/ngettext.c"
"intl/osdep.c"
"intl/plural-exp.c"
"intl/plural.c"
"intl/printf.c"
"intl/relocatable.c"
"intl/textdomain.c"
"intl/version.c"
)

set(LOCALDIR "c:/gettext")

add_definitions(-DLOCALEDIR=\"${LOCALDIR}\")
add_definitions(-DLOCALE_ALIAS_PATH=\"${LOCALDIR}\")
add_definitions(-DLIBDIR=\"${LOCALDIR}\")
add_definitions(-DINSTALLDIR=\"${LOCALDIR}\")
if(BUILD_SHARED_LIBS)
  add_definitions(-DBUILDING_DLL)
endif()
add_definitions("-DBUILDING_LIBINTL -DIN_LIBINTL -DENABLE_RELOCATABLE=1 -DIN_LIBRARY")

add_definitions("-DNO_XMALLOC -Dset_relocation_prefix=libintl_set_relocation_prefix -Drelocate=libintl_relocate -DDEPENDS_ON_LIBICONV=1 -DHAVE_CONFIG_H -D_CRT_SECURE_NO_WARNINGS")

add_library(libintl ${SOURCES})

install(TARGETS libintl
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION bin
  ARCHIVE DESTINATION lib
)

