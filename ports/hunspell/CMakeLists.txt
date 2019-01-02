cmake_minimum_required(VERSION 3.0)
project(hunspell)

#get hunspell version
file(STRINGS "configure.ac" CONFIGURE_AC_INIT REGEX "AC_INIT\\(\\[hunspell\\],\\[.*\\].*" )
string(REGEX REPLACE "AC_INIT\\(\\[.*\\],\\[([0-9]+\\.[0-9]+\\.[0-9]+)\\].*" "\\1"  VERSION ${CONFIGURE_AC_INIT})
message(STATUS "Hunspell version: ${VERSION}")

option(BUILD_SHARED_LIBS "Build shared libs" OFF)
option(ENABLE_NLS "Define if translation of program messages to the user's native language is requested" OFF)
option(HUNSPELL_WARNING_ON "Define if you need warning messages" OFF)

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DHUNSPELL_STATIC)
endif()

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories("src/hunspell")
include_directories("src/parsers")

#libhunspell
set(LIBHUNSPELL_SRCS
    src/hunspell/affentry.cxx
    src/hunspell/affixmgr.cxx
    src/hunspell/csutil.cxx
    src/hunspell/hashmgr.cxx
    src/hunspell/hunspell.cxx
    src/hunspell/suggestmgr.cxx
    src/hunspell/phonet.cxx
    src/hunspell/filemgr.cxx
    src/hunspell/hunzip.cxx
    src/hunspell/replist.cxx
    src/hunspell/affentry.hxx
    src/hunspell/htypes.hxx
    src/hunspell/affixmgr.hxx
    src/hunspell/csutil.hxx
    src/hunspell/atypes.hxx
    src/hunspell/suggestmgr.hxx
    src/hunspell/baseaffix.hxx
    src/hunspell/hashmgr.hxx
    src/hunspell/langnum.hxx
    src/hunspell/phonet.hxx
    src/hunspell/filemgr.hxx
    src/hunspell/hunzip.hxx
    src/hunspell/replist.hxx
)

set(LIBHUNSPELL_HDRS
    src/hunspell/hunspell.hxx 
    src/hunspell/hunspell.h 
    src/hunspell/hunvisapi.h
    src/hunspell/w_char.hxx 
    src/hunspell/atypes.hxx 
    src/hunspell/csutil.hxx
    src/hunspell/htypes.hxx
)

#hunspell/libhunspell
add_library(libhunspell ${LIBHUNSPELL_HDRS} ${LIBHUNSPELL_SRCS})
target_compile_definitions(libhunspell PRIVATE -DBUILDING_LIBHUNSPELL)
install(TARGETS libhunspell
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

#parsers/libparsers
set(LIBPARSERS_SRCS
    src/parsers/firstparser.cxx
    src/parsers/xmlparser.cxx
    src/parsers/latexparser.cxx
    src/parsers/manparser.cxx
    src/parsers/textparser.cxx
    src/parsers/htmlparser.cxx
    src/parsers/odfparser.cxx
)
add_library(libparsers OBJECT ${LIBPARSERS_SRCS})

#parsers/testparser
set(TESTPARSER_SRCS
    src/parsers/firstparser.cxx
    src/parsers/firstparser.hxx
    src/parsers/xmlparser.cxx
    src/parsers/xmlparser.hxx
    src/parsers/latexparser.cxx
    src/parsers/latexparser.hxx
    src/parsers/manparser.cxx 
    src/parsers/manparser.hxx
    src/parsers/testparser.cxx
    src/parsers/textparser.cxx
    src/parsers/textparser.hxx
    src/parsers/htmlparser.cxx
    src/parsers/htmlparser.hxx
    src/parsers/odfparser.hxx
    src/parsers/odfparser.cxx
)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND CMAKE_BUILD_TYPE STREQUAL "Release")
    add_executable(testparser ${TESTPARSER_SRCS})
    target_link_libraries(testparser libhunspell)

    #tools/analyze
    add_executable(analyze "src/tools/analyze.cxx")
    target_link_libraries(analyze libhunspell)

    #tools/chmorph
    add_executable(chmorph "src/tools/chmorph.cxx" $<TARGET_OBJECTS:libparsers>)
    target_link_libraries(chmorph libhunspell)

    #tools/hunspell
    include(CheckIncludeFile)
    check_include_file("curses.h" HAVE_CURSES_H)
    check_include_file("langinfo.h" HAVE_LANGINFO_CODESET)
    check_include_file("libintl.h" HAVE_LIBINTL_H)
    check_include_file("locale.h" HAVE_LOCALE_H)
    check_include_file("ncursesw/curses.h" HAVE_NCURSESW_H)
    check_include_file("unistd.h" HAVE_UNISTD_H)
    configure_file("config.h.in" "config.h")

    add_executable(hunspell "src/tools/hunspell.cxx" $<TARGET_OBJECTS:libparsers>)
    target_include_directories(hunspell PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
    target_link_libraries(hunspell libhunspell)

    #tools/munch
    add_executable(munch "src/tools/munch.cxx")

    #tools/unmunch
    add_executable(unmunch "src/tools/unmunch.cxx")

    #tools/hzip
    #add_executable(hzip "src/tools/hzip.cxx")
    #target_link_libraries(hzip libhunspell)

    #tools/hunzip
    add_executable(hunzip "src/tools/hunzip.cxx")
    target_link_libraries(hunzip libhunspell)

    install(
        TARGETS
            hunspell 
            testparser
            analyze
            chmorph
            munch
            unmunch
        #    hzip
            hunzip 
        DESTINATION tools/hunspell
    )
endif()

install(FILES ${LIBHUNSPELL_HDRS} DESTINATION "include/hunspell/")
