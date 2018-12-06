cmake_minimum_required(VERSION 3.0)
project(readline C)

add_definitions(-DREADLINE_LIBRARY)
add_definitions(-DHAVE_CONFIG_H)
add_definitions(-D_CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    add_definitions(-DBUILD_READLINE_DLL)
else()
    add_definitions(-DREADLINE_STATIC)
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR} # thats where the config.h is located
)

add_library(readline
    readline.c
    funmap.c
    keymaps.c
	vi_mode.c
    parens.c
    rltty.c
    complete.c
    bind.c
    isearch.c
    display.c
    signals.c
    util.c
    kill.c
	undo.c
    macro.c
    input.c
	callback.c
    terminal.c
    xmalloc.c
	history.c
    histsearch.c
    histexpand.c
	histfile.c
    nls.c
    search.c
	shell.c
    savestring.c
    tilde.c
	text.c
    misc.c
    compat.c
	mbutil.c
    support/wcwidth.c)

install(TARGETS readline
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
