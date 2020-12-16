cmake_minimum_required(VERSION 3.0)
project(gdk-pixbuf C)

set(GDK_PIXBUF_LIB_SUFFIX 2.0)
set(GDK_PIXBUF_DLL_SUFFIX 2)
set(GDK_PIXBUF_BINARY_VERSION 2.10.0)
set(GLIB_LIB_VERSION 2.0)

find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)

find_package(unofficial-glib CONFIG REQUIRED)
find_path(GLIB_INCLUDE_DIR glib.h)

find_package(Intl REQUIRED)
find_path(LIBINTL_INCLUDE_DIR libintl.h)
    
if(WIN32)
    configure_file(${CMAKE_SOURCE_DIR}/config.h.win32 ${CMAKE_SOURCE_DIR}/config.h COPYONLY)
else()
    configure_file(${CMAKE_SOURCE_DIR}/config.h.linux ${CMAKE_SOURCE_DIR}/config.h COPYONLY)
endif()
include_directories(. ./gdk-pixbuf)

set(SOURCES
    gdk-pixbuf/gdk-pixbuf.c
    gdk-pixbuf/gdk-pixbuf-animation.c
    gdk-pixbuf/gdk-pixbuf-data.c
    gdk-pixbuf/gdk-pixbuf-io.c
    gdk-pixbuf/gdk-pixbuf-loader.c
    gdk-pixbuf/gdk-pixbuf-scale.c
    gdk-pixbuf/gdk-pixbuf-simple-anim.c
    gdk-pixbuf/gdk-pixbuf-scaled-anim.c
    gdk-pixbuf/gdk-pixbuf-util.c
    gdk-pixbuf/gdk-pixdata.c
    gdk-pixbuf/gdk-pixbuf-enum-types.c
    gdk-pixbuf/gdk-pixbuf-marshal.c
    gdk-pixbuf/io-ani.c
    gdk-pixbuf/io-ani-animation.c
    gdk-pixbuf/io-icns.c
    gdk-pixbuf/io-pnm.c
    gdk-pixbuf/io-png.c
    gdk-pixbuf/io-qtif.c
    gdk-pixbuf/io-tga.c
    gdk-pixbuf/gdk-pixbuf-buffer-queue.c
    gdk-pixbuf/io-xpm.c
    gdk-pixbuf/io-xbm.c
    gdk-pixbuf/pixops/pixops.c
)
if(WIN32)
    list(APPEND SOURCES
    gdk-pixbuf/io-gdip-animation.c
    gdk-pixbuf/io-gdip-bmp.c
    gdk-pixbuf/io-gdip-emf.c
    gdk-pixbuf/io-gdip-gif.c
    gdk-pixbuf/io-gdip-ico.c
    gdk-pixbuf/io-gdip-jpeg.c
    gdk-pixbuf/io-gdip-tiff.c
    gdk-pixbuf/io-gdip-utils.c
    gdk-pixbuf/io-gdip-wmf.c
)
endif()
add_library(gdk-pixbuf ${SOURCES})

target_include_directories(gdk-pixbuf PRIVATE 
    ${GLIB_INCLUDE_DIR} 
    ${PNG_INCLUDE_DIRS}
    ${ZLIB_INCLUDE_DIRS}
    ${Intl_INCLUDE_DIR})

set(LIBS 
    unofficial::glib::gio unofficial::glib::glib unofficial::glib::gmodule unofficial::glib::gobject ${Intl_LIBRARIES}
    ${ZLIB_LIBRARIES} 
    ${PNG_LIBRARIES} 
)
if(WIN32)
    list(APPEND LIBS Gdiplus ole32)
else()
    list(APPEND LIBS m)
endif()

target_link_libraries(gdk-pixbuf ${LIBS})

set(DEFS
    HAVE_CONFIG_H
    GDK_PIXBUF_COMPILATION
    GDK_PIXBUF_ENABLE_BACKEND
    DLL_EXPORT
    GDK_PIXBUF_RELOCATABLE
    GDK_PIXBUF_PREFIX="/dummy"
    GDK_PIXBUF_BINARY_VERSION="${GDK_PIXBUF_BINARY_VERSION}"
    INCLUDE_ani
    INCLUDE_tga
    INCLUDE_xbm
    INCLUDE_png
    INCLUDE_qtif
    INCLUDE_pnm
    INCLUDE_icns
    INCLUDE_xpm
    G_DISABLE_SINGLE_INCLUDES
    GDK_PIXBUF_DISABLE_SINGLE_INCLUDES)
if(WIN32)
    list(APPEND DEFS INCLUDE_gdiplus)
endif()
target_compile_definitions(gdk-pixbuf PRIVATE ${DEFS})

set_target_properties(gdk-pixbuf PROPERTIES 
    OUTPUT_NAME gdk_pixbuf-${GDK_PIXBUF_DLL_SUFFIX}
    ARCHIVE_OUTPUT_NAME gdk_pixbuf-${GDK_PIXBUF_LIB_SUFFIX})

install(TARGETS gdk-pixbuf
    RUNTIME DESTINATION bin 
    ARCHIVE DESTINATION lib 
    LIBRARY DESTINATION lib)

macro(gdk_add_tool TOOL_NAME)
    add_executable(${TOOL_NAME} ${ARGN})
    target_include_directories(${TOOL_NAME} PRIVATE ${GLIB_INCLUDE_DIR})
    target_link_libraries(${TOOL_NAME} gdk-pixbuf ${GLIB_LIBRARIES})
    install(TARGETS ${TOOL_NAME} RUNTIME DESTINATION tools/gdk-pixbuf)
endmacro()  

if(NOT GDK_SKIP_TOOLS)
    gdk_add_tool(gdk-pixbuf-csource gdk-pixbuf/gdk-pixbuf-csource.c)
    gdk_add_tool(gdk-pixbuf-pixdata gdk-pixbuf/gdk-pixbuf-pixdata.c)
endif()

if(NOT GDK_SKIP_HEADERS)
    INSTALL(FILES
        gdk-pixbuf/gdk-pixbuf.h
        gdk-pixbuf/gdk-pixbuf-autocleanups.h
        gdk-pixbuf/gdk-pixbuf-core.h 
        gdk-pixbuf/gdk-pixbuf-transform.h 
        gdk-pixbuf/gdk-pixbuf-io.h 
        gdk-pixbuf/gdk-pixbuf-animation.h 
        gdk-pixbuf/gdk-pixbuf-simple-anim.h
        gdk-pixbuf/gdk-pixbuf-loader.h 
        gdk-pixbuf/gdk-pixbuf-enum-types.h 
        gdk-pixbuf/gdk-pixbuf-marshal.h 
        gdk-pixbuf/gdk-pixbuf-features.h 
        gdk-pixbuf/gdk-pixdata.h
        gdk-pixbuf/gdk-pixbuf-macros.h
        DESTINATION include/gdk-pixbuf)
endif()
