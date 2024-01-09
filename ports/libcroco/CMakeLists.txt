cmake_minimum_required(VERSION 3.11)
project(libcroco C)

find_package(PkgConfig REQUIRED)
set(libcroco_pc_requires glib-2.0 libxml-2.0)
pkg_check_modules(LIBCROCO_LINK_PUBLIC ${libcroco_pc_requires} IMPORTED_TARGET REQUIRED)

file(GLOB SOURCES
	src/cr-utils.c
	src/cr-utils.h
	src/cr-input.c
	src/cr-input.h
	src/cr-enc-handler.c
	src/cr-enc-handler.h
	src/cr-num.c
	src/cr-num.h
	src/cr-rgb.c
	src/cr-rgb.h
	src/cr-token.c
	src/cr-token.h
	src/cr-tknzr.c
	src/cr-tknzr.h
	src/cr-term.c
	src/cr-term.h
	src/cr-attr-sel.c
	src/cr-attr-sel.h
	src/cr-pseudo.c
	src/cr-pseudo.h
	src/cr-additional-sel.c
	src/cr-additional-sel.h
	src/cr-simple-sel.c
	src/cr-simple-sel.h
	src/cr-selector.c
	src/cr-selector.h
	src/cr-doc-handler.c
	src/cr-doc-handler.h
	src/cr-parser.c
	src/cr-parser.h
	src/cr-declaration.c
	src/cr-declaration.h
	src/cr-statement.c
	src/cr-statement.h
	src/cr-stylesheet.c
	src/cr-stylesheet.h
	src/cr-cascade.c
	src/cr-cascade.h
	src/cr-om-parser.c
	src/cr-om-parser.h
	src/cr-style.c
	src/cr-style.h
	src/cr-sel-eng.c
	src/cr-sel-eng.h
	src/cr-fonts.c
	src/cr-fonts.h
	src/cr-prop-list.c
	src/cr-prop-list.h
	src/cr-parsing-location.c
	src/cr-parsing-location.h
	src/cr-string.c
	src/cr-string.h
	src/libcroco.def
)

add_library(croco-0.6 ${SOURCES})
target_link_libraries(croco-0.6 PRIVATE PkgConfig::LIBCROCO_LINK_PUBLIC)

install(TARGETS croco-0.6
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES
	src/libcroco.h
	src/cr-additional-sel.h
	src/cr-attr-sel.h
	src/cr-cascade.h
	src/cr-declaration.h
	src/cr-doc-handler.h
	src/cr-enc-handler.h
	src/cr-input.h
	src/cr-num.h
	src/cr-om-parser.h
	src/cr-parser.h
	src/cr-pseudo.h
	src/cr-rgb.h
	src/cr-selector.h
	src/cr-simple-sel.h
	src/cr-statement.h
	src/cr-stylesheet.h
	src/cr-term.h
	src/cr-tknzr.h
	src/cr-token.h
	src/cr-utils.h
	src/cr-fonts.h
	src/cr-sel-eng.h
	src/cr-style.h
	src/cr-prop-list.h
	src/cr-parsing-location.h
	src/cr-string.h
	src/libcroco-config.h
    DESTINATION include/libcroco-0.6/libcroco
)

string(REGEX MATCH "^([0-9]*)[.]([0-9]*)[.].*" unused "${VERSION}" )
set(LIBCROCO_MAJOR_VERSION "${CMAKE_MATCH_1}")
set(LIBCROCO_MINOR_VERSION "${CMAKE_MATCH_2}")

set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/libcroco.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/libcroco.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libcroco.pc"
	DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
	RENAME "libcroco-${LIBCROCO_MAJOR_VERSION}.${LIBCROCO_MINOR_VERSION}.pc"
)
