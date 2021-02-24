cmake_minimum_required(VERSION 3.11)
project(librsvg C)

find_package(unofficial-cairo CONFIG REQUIRED)
find_package(unofficial-libcroco CONFIG REQUIRED)
find_package(unofficial-glib CONFIG REQUIRED)
find_package(LibXml2 REQUIRED)
if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  find_library(PANGO_LIB pango-1.0)
  find_library(PANGO_CAIRO_LIB pangocairo-1.0)
  find_library(GDK_PIXBUF_LIB gdk_pixbuf-2.0)
elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
  find_library(PANGO_LIB pango-1.0)
  find_library(PANGO_CAIRO_LIB pangocairo-1.0)
  find_library(GDK_PIXBUF_LIB gdk_pixbuf-2)
else()
  find_library(PANGO_LIB pango-1)
  find_library(PANGO_CAIRO_LIB pangocairo-1)
  find_library(PANGO_FT2_LIB pangoft2-1)
  find_library(FONTCONFIG_LIB fontconfig)
  find_library(GDK_PIXBUF_LIB gdk_pixbuf-2)
endif()

find_path(CAIRO_INCLUDE_DIR cairo/cairo.h)

# Add include directories
include_directories(${CAIRO_INCLUDE_DIR} ${GDK_PIXBUF_INCLUDE_DIR})

set(LIBRSVG_SOURCES
    librsvg-features.c
    rsvg-css.c
    rsvg-css.h
    rsvg-compat.h
    rsvg-defs.c
    rsvg-defs.h
    rsvg-image.c
    rsvg-image.h
    rsvg-io.c
    rsvg-io.h
    rsvg-paint-server.c
    rsvg-paint-server.h
    rsvg-path.c
    rsvg-path.h
    rsvg-private.h
    rsvg-base-file-util.c
    rsvg-filter.c
    rsvg-filter.h
    rsvg-marker.c
    rsvg-marker.h
    rsvg-mask.c
    rsvg-mask.h
    rsvg-shapes.c
    rsvg-shapes.h
    rsvg-structure.c
    rsvg-structure.h
    rsvg-styles.c
    rsvg-styles.h
    rsvg-text.c
    rsvg-text.h
    rsvg-cond.c
    rsvg-base.c
    librsvg-enum-types.c
    rsvg-cairo-draw.c
    rsvg-cairo-draw.h
    rsvg-cairo-render.c
    rsvg-cairo-render.h
    rsvg-cairo-clip.h
    rsvg-cairo-clip.c
    rsvg.c
    rsvg-gobject.c
    rsvg-file-util.c
    rsvg-size-callback.c
    rsvg-size-callback.h
    rsvg-xml.c
    rsvg-xml.h
    rsvg.h
    rsvg-cairo.h
    librsvg-features.h
    librsvg-enum-types.h
)

set(PIXBUFLOADERSVG_SOURCES 
    gdk-pixbuf-loader/io-svg.c
)

if(WIN32)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.win32 ${CMAKE_CURRENT_SOURCE_DIR}/config.h COPYONLY)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/rsvg.def
        COMMAND echo "EXPORTS" > ${CMAKE_CURRENT_SOURCE_DIR}/rsvg.def
        COMMAND ${CMAKE_C_COMPILER} /EP ${CMAKE_CURRENT_SOURCE_DIR}/rsvg.symbols >> ${CMAKE_CURRENT_SOURCE_DIR}/rsvg.def)
    list(APPEND LIBRSVG_SOURCES rsvg.def)
else()
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.linux ${CMAKE_CURRENT_SOURCE_DIR}/config.h COPYONLY)
    list(APPEND LIBRSVG_SOURCES rsvg.symbols)
endif()

set(CMAKE_DEBUG_POSTFIX "d")

add_library(rsvg-2.40 ${LIBRSVG_SOURCES})
add_library(pixbufloader-svg ${PIXBUFLOADERSVG_SOURCES})

target_compile_definitions(rsvg-2.40 PRIVATE -DRSVG_COMPILATION -D_CRT_SECURE_NO_WARNINGS -DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")

target_include_directories(pixbufloader-svg PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(pixbufloader-svg PRIVATE 
    -DRSVG_COMPILATION 
    -D_CRT_SECURE_NO_WARNINGS
    -DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}" 
    -DGDK_PIXBUF_ENABLE_BACKEND 
    -DG_LOG_DOMAIN="libpixbufloader-svg")

target_link_libraries(rsvg-2.40 PRIVATE
    unofficial::cairo::cairo
    unofficial::libcroco::croco-0.6
    unofficial::glib::gio
    unofficial::glib::glib
    unofficial::glib::gmodule
    unofficial::glib::gobject
    ${LIBXML2_LIBRARIES}
    ${PANGO_LIB}
    ${PANGO_CAIRO_LIB}
    ${GDK_PIXBUF_LIB}
    ${PANGO_FT2_LIB}
    ${FONTCONFIG_LIB}
)
target_link_libraries(pixbufloader-svg PRIVATE
    rsvg-2.40
    unofficial::glib::glib
    unofficial::glib::gobject
    ${GDK_PIXBUF_LIB}
)

install(TARGETS rsvg-2.40 pixbufloader-svg
    EXPORT librsvg-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT librsvg-targets
    NAMESPACE unofficial::librsvg::
    FILE unofficial-librsvg-targets.cmake
    DESTINATION share/unofficial-librsvg
)

install(FILES
	rsvg.h
	rsvg-cairo.h
    librsvg-features.h
    librsvg-enum-types.h
    DESTINATION include/librsvg
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/unofficial-librsvg-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-cairo CONFIG)
find_dependency(unofficial-libcroco CONFIG)
find_dependency(gdk-pixbuf CONFIG)
find_dependency(pango CONFIG)

include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-librsvg-targets.cmake)
")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-librsvg-config.cmake DESTINATION share/unofficial-librsvg)
