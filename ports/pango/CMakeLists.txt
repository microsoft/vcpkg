cmake_minimum_required(VERSION 3.0)
project(pango C)

set(PANGO_LIB_SUFFIX 1.0)
set(PANGO_DLL_SUFFIX 1)
set(GLIB_LIB_VERSION 2.0)

if(WIN32)
  configure_file(./config.h.win32 ${CMAKE_CURRENT_BINARY_DIR}/config.h COPYONLY)
else()
  configure_file(./config.h.unix ${CMAKE_CURRENT_BINARY_DIR}/config.h COPYONLY)
endif()

if (WIN32)
  # Set utf-8 charset to avoid compile error C2001
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /utf-8")
endif()

add_definitions(-DHAVE_CONFIG_H)
include_directories(. ./pango ${CMAKE_CURRENT_BINARY_DIR})

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
# find libintl
find_path(LIBINTL_INCLUDE_DIR libintl.h)
find_library(LIBINTL_LIBRARY NAMES libintl intl)
endif()

# find glib
find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_GLIB_LIBRARY glib-${GLIB_LIB_VERSION})
find_library(GLIB_GOBJECT_LIBRARY gobject-${GLIB_LIB_VERSION})
find_library(GLIB_GMODULE_LIBRARY gmodule-${GLIB_LIB_VERSION})
set(GLIB_LIBRARIES ${GLIB_GLIB_LIBRARY} ${GLIB_GOBJECT_LIBRARY} ${GLIB_GMODULE_LIBRARY})

# find cairo
find_path(CAIRO_INCLUDE_DIR cairo.h)
if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(CAIRO_SUFFIX d)
endif()
find_library(CAIRO_LIBRARY 
    NAMES
        cairo${CAIRO_SUFFIX}
        cairo-static${CAIRO_SUFFIX})
find_library(CAIRO_GOBJECT_LIBRARY cairo-gobject${CAIRO_SUFFIX})
set(CAIRO_LIBRARIES ${CAIRO_LIBRARY} ${CAIRO_GOBJECT_LIBRARY})

# find fontconfig
find_path(FONTCONFIG_INCLUDE_DIR fontconfig/fontconfig.h)
find_library(FONTCONFIG_LIBRARY fontconfig)

# find freetype
find_package(Freetype REQUIRED)

# find harfbuzz
find_path(HARFBUZZ_INCLUDE_DIR harfbuzz/hb.h)
find_library(HARFBUZZ_LIBRARY harfbuzz)

if (APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    link_libraries(${COREFOUNDATION_LIBRARY})
endif()

set(FONT_INCLUDE_DIRS ${FREETYPE_INCLUDE_DIR} ${FONTCONFIG_INCLUDE_DIR} ${HARFBUZZ_INCLUDE_DIR}/harfbuzz)
set(FONT_LIBRARIES Freetype::Freetype ${FONTCONFIG_LIBRARY} ${HARFBUZZ_LIBRARY})

macro(pango_add_module MODULE_NAME)
    add_library(${MODULE_NAME} ${ARGN})
    target_include_directories(${MODULE_NAME} PRIVATE ${GLIB_INCLUDE_DIR} ${LIBINTL_INCLUDE_DIR})
    target_link_libraries(${MODULE_NAME} ${LIBINTL_LIBRARY} ${GLIB_LIBRARIES})
    target_compile_definitions(${MODULE_NAME} PRIVATE
        G_LOG_DOMAIN="Pango" PANGO_ENABLE_BACKEND PANGO_ENABLE_ENGINE 
        G_DISABLE_SINGLE_INCLUDES SYSCONFDIR="/dummy/etc" LIBDIR="/dummy/lib")
    target_compile_definitions(${MODULE_NAME} PRIVATE HAVE_CAIRO_FREETYPE=1)
    set_target_properties(${MODULE_NAME} PROPERTIES
        DEFINE_SYMBOL PANGO_EXPORTS
        OUTPUT_NAME ${MODULE_NAME}-${PANGO_DLL_SUFFIX}
        ARCHIVE_OUTPUT_NAME ${MODULE_NAME}-${PANGO_LIB_SUFFIX})
    install(TARGETS ${MODULE_NAME} RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
endmacro()

pango_add_module(pango
    pango/break-arabic.c
    pango/break-indic.c
    pango/mini-fribidi/fribidi.c
    pango/mini-fribidi/fribidi_char_type.c
    pango/mini-fribidi/fribidi_types.c
    pango/break.c
    pango/ellipsize.c
    pango/fonts.c
    pango/glyphstring.c
    pango/modules.c
    pango/pango-attributes.c
    pango/pango-bidi-type.c
    pango/pango-color.c
    pango/pango-context.c
    pango/pango-coverage.c
    pango/pango-emoji.c
    pango/pango-engine.c
    pango/pango-fontmap.c
    pango/pango-fontset.c
    pango/pango-glyph-item.c
    pango/pango-gravity.c
    pango/pango-item.c
    pango/pango-language.c
    pango/pango-layout.c
    pango/pango-markup.c
    pango/pango-matrix.c
    pango/pango-renderer.c
    pango/pango-script.c
    pango/pango-tabs.c
    pango/pango-utils.c
    pango/reorder-items.c
    pango/shape.c
    pango/pango-enum-types.c)

if(WIN32)
pango_add_module(pangowin32
    pango/pangowin32.c
    pango/pangowin32-fontcache.c
    pango/pangowin32-fontmap.c
    pango/pangowin32-shape.c)
target_link_libraries(pangowin32 usp10 pango gdi32)
endif()

pango_add_module(pangoft2
    pango/pangofc-font.c
    pango/pangofc-fontmap.c
    pango/pangofc-decoder.c
    pango/pangofc-shape.c
    pango/pangoft2.c
    pango/pangoft2-fontmap.c
    pango/pangoft2-render.c
    pango/pango-ot-buffer.c
    pango/pango-ot-info.c
    pango/pango-ot-ruleset.c
    pango/pango-ot-tag.c)
target_link_libraries(pangoft2 pango ${FONT_LIBRARIES})
target_include_directories(pangoft2 PRIVATE ${FONT_INCLUDE_DIRS})

list(APPEND PANGO_CAIRO_SOURCES 
	pango/pangocairo-fcfont.c
    pango/pangocairo-fcfontmap.c
    pango/pangocairo-context.c
    pango/pangocairo-font.c
    pango/pangocairo-fontmap.c
    pango/pangocairo-render.c)
	
if(WIN32)
	list(APPEND PANGO_CAIRO_SOURCES 
		pango/pangocairo-win32font.c
		pango/pangocairo-win32fontmap.c)
endif()

pango_add_module(pangocairo ${PANGO_CAIRO_SOURCES})
list(APPEND PANGO_CAIRO_LIBRARIES  ${CAIRO_LIBRARIES} pango pangoft2 ${FONT_LIBRARIES})
if (WIN32)
    list(APPEND PANGO_CAIRO_LIBRARIES pangowin32)
endif()
target_link_libraries(pangocairo ${PANGO_CAIRO_LIBRARIES}) 
target_include_directories(pangocairo PRIVATE ${CAIRO_INCLUDE_DIR} ${FONT_INCLUDE_DIRS})


if(NOT PANGO_SKIP_HEADERS)
    install(FILES
        pango/pango.h 
        pango/pango-attributes.h 
        pango/pango-bidi-type.h 
        pango/pango-break.h 
        pango/pango-context.h 
        pango/pango-coverage.h 
        pango/pango-engine.h 
        pango/pango-font.h 
        pango/pango-fontmap.h 
        pango/pango-fontset.h 
        pango/pango-glyph.h 
        pango/pango-glyph-item.h 
        pango/pango-gravity.h 
        pango/pango-item.h 
        pango/pango-language.h 
        pango/pango-layout.h 
        pango/pango-matrix.h 
        pango/pango-modules.h 
        pango/pango-renderer.h 
        pango/pango-script.h 
        pango/pango-tabs.h 
        pango/pango-types.h 
        pango/pango-utils.h 
        pango/pango-version-macros.h 
        pango/pangocairo.h 
        pango/pangowin32.h 
        pango/pango-features.h 
        pango/pango-enum-types.h
        pango/pangofc-decoder.h 
        pango/pangofc-font.h 
        pango/pangofc-fontmap.h 
        pango/pango-ot.h 
        pango/pangoft2.h 
        DESTINATION include/pango)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${LIBINTL_LIBRARY})
foreach(GL ${GLIB_LIBRARIES})
    message(STATUS "  " ${GL})
endforeach()
foreach(CL ${CAIRO_LIBRARIES})
    message(STATUS "  " ${CL})
endforeach()
foreach(FL ${FONT_LIBRARIES})
    message(STATUS "  " ${FL})
endforeach()
