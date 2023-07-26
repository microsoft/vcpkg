cmake_minimum_required(VERSION 3.11)
project(librsvg C)

set(RSVG_API_MAJOR_VERSION 2)
set(RSVG_API_VERSION "2.0")
Set(VERSION "2.40.20")
set(targets "rsvg-${RSVG_API_MAJOR_VERSION}")

Set(prefix "${CMAKE_INSTALL_PREFIX}")
Set(exec_prefix "\${prefix}")
Set(libdir "\${prefix}/lib")
Set(includedir "\${prefix}/include")

find_package(unofficial-libcroco CONFIG REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 glib-2.0 gobject-2.0 gmodule-2 gio-2 IMPORTED_TARGET)
pkg_check_modules(CAIRO cairo IMPORTED_TARGET)
pkg_check_modules(GDK_PIXBUF gdk-pixbuf-2.0 IMPORTED_TARGET)
pkg_check_modules(PANGO pango pangocairo IMPORTED_TARGET)
find_package(LibXml2 REQUIRED)
if(CMAKE_SYSTEM_NAME MATCHES "Windows")
elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
else()
    pkg_check_modules(PANGO2 pangoft2 pangofc IMPORTED_TARGET)
    set(PANGO_FT2_LIB PkgConfig::PANGO2)
endif()

# Add include directories
include_directories(${CAIRO_INCLUDE_DIRS} ${GDK_PIXBUF_INCLUDE_DIRS} ${GLIB2_INCLUDE_DIRS} ${PANGO_INCLUDE_DIRS} ${PANGO2_INCLUDE_DIRS})

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

add_library(${targets} ${LIBRSVG_SOURCES})
add_library(pixbufloader-svg ${PIXBUFLOADERSVG_SOURCES})

target_compile_definitions(${targets} PRIVATE -DRSVG_COMPILATION -D_CRT_SECURE_NO_WARNINGS -DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")

target_include_directories(pixbufloader-svg PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(pixbufloader-svg PRIVATE 
    -DRSVG_COMPILATION 
    -D_CRT_SECURE_NO_WARNINGS
    -DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}" 
    -DGDK_PIXBUF_ENABLE_BACKEND 
    -DG_LOG_DOMAIN="libpixbufloader-svg")

target_link_libraries(${targets} PRIVATE
    PkgConfig::GLIB2
    ${LIBXML2_LIBRARIES}
    PkgConfig::PANGO
    PkgConfig::GDK_PIXBUF
    ${PANGO_FT2_LIB}
    unofficial::libcroco::croco-0.6
)
target_link_libraries(pixbufloader-svg PRIVATE
    ${targets}
    PkgConfig::GLIB2
    PkgConfig::GDK_PIXBUF
)

install(TARGETS ${targets} pixbufloader-svg
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
    DESTINATION include/librsvg-${RSVG_API_VERSION}
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/unofficial-librsvg-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(PkgConfig)
pkg_check_modules(GLIB2 glib-2.0 gobject-2.0 gmodule-2 gio-2 IMPORTED_TARGET)
pkg_check_modules(CAIRO cairo IMPORTED_TARGET)
pkg_check_modules(GDK_PIXBUF gdk-pixbuf IMPORTED_TARGET)
pkg_check_modules(PANGO pango pangocairo IMPORTED_TARGET)
find_dependency(unofficial-libcroco CONFIG)

include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-librsvg-targets.cmake)
")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-librsvg-config.cmake DESTINATION share/unofficial-librsvg)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/librsvg.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/librsvg.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/librsvg.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
