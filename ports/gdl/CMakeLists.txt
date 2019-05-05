cmake_minimum_required(VERSION 3.0)
project(gdl C)

set(GDL_LIB_SUFFIX 1.0)
set(GDL_DLL_SUFFIX 1)
set(GLIB_LIB_VERSION 2.0)
set(GDK_PIXBUF_LIB_SUFFIX 2.0)
set(GDK_LIB_SUFFIX 3.0)
set(GTK_LIB_SUFFIX 3.0)

if(BUILD_SHARED_LIBS)
    set(GDL_EXPORT_MACRO DLL_EXPORT)
endif()

add_definitions(-DHAVE_CONFIG_H)
include_directories(. ./gdl ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/gdl)

# glib
find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_GLIB_LIBRARY glib-${GLIB_LIB_VERSION})
find_library(GLIB_GOBJECT_LIBRARY gobject-${GLIB_LIB_VERSION})
find_library(GLIB_GMODULE_LIBRARY gmodule-${GLIB_LIB_VERSION})
set(GLIB_LIBRARIES ${GLIB_GLIB_LIBRARY} ${GLIB_GOBJECT_LIBRARY} ${GLIB_GMODULE_LIBRARY})

# gdk-pixbuf
find_path(GDK_PIXBUF_INCLUDE_DIR gdk-pixbuf/gdk-pixbuf.h)
find_library(GDK_PIXBUF_LIBRARY gdk_pixbuf-${GDK_PIXBUF_LIB_SUFFIX})

# gettext
find_path(LIBINTL_INCLUDE_DIR libintl.h)
find_library(LIBINTL_LIBRARY libintl)

# gdk
find_path(GDK_INCLUDE_DIR gdk/gdk.h)
find_library(GDK_LIBRARY gdk-${GDK_LIB_SUFFIX})

# gtk
find_path(GTK_INCLUDE_DIR gtk/gtk.h)
find_library(GTK_LIBRARY gtk-${GTK_LIB_SUFFIX})

# cairo
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_library(CAIRO_LIBRARY cairod)
else()
    find_library(CAIRO_LIBRARY cairo)
endif()

# libxml2
find_library(LIBXML2_LIBRARY libxml2)

set(GDL_REQUIRED_INCLUDE_DIRS
    ${LIBINTL_INCLUDE_DIR}
    ${GLIB_INCLUDE_DIR}
    ${GDK_PIXBUF_INCLUDE_DIR}
    ${GDK_INCLUDE_DIR}
    ${GTK_INCLUDE_DIR}
)

set(GDL_REQUIRED_LIBRARIES
    ${LIBINTL_LIBRARY}
    ${GLIB_LIBRARIES}
    ${GDK_PIXBUF_LIBRARY}
    ${GDK_LIBRARY}
    ${GTK_LIBRARY}
    ${CAIRO_LIBRARY}
    ${LIBXML2_LIBRARY}
)

set(GDL_SOURCES
    gdl/gdl-dock-object.c
    gdl/gdl-dock-master.c
    gdl/gdl-dock.c
    gdl/gdl-dock-item.c
    gdl/gdl-dock-item-button-image.h
    gdl/gdl-dock-item-button-image.c
    gdl/gdl-dock-item-grip.h
    gdl/gdl-dock-item-grip.c
    gdl/gdl-dock-notebook.h
    gdl/gdl-dock-notebook.c
    gdl/gdl-dock-paned.c
    gdl/gdl-dock-paned.h
    gdl/deprecated/gdl-dock-tablabel.c
    gdl/deprecated/gdl-dock-tablabel.h
    gdl/gdl-dock-layout.c
    gdl/gdl-dock-placeholder.c
    gdl/gdl-dock-bar.c
    gdl/gdl-switcher.c
    gdl/gdl-switcher.h
    gdl/gdl-preview-window.h
    gdl/gdl-preview-window.c
    gdl/gdl-deprecated.c

    gdl/libgdltypebuiltins.h
    gdl/libgdltypebuiltins.c
    gdl/libgdlmarshal.h
    gdl/libgdlmarshal.c
)

add_library(gdl ${GDL_SOURCES})
target_compile_definitions(gdl PRIVATE GDL_COMPILATION ${GDL_EXPORT_MACRO} G_DISABLE_SINGLE_INCLUDES GDL_LOCALEDIR="/dummy/share/locale")
target_link_libraries(gdl ${GDL_REQUIRED_LIBRARIES})
target_include_directories(gdl PRIVATE ${GDL_REQUIRED_INCLUDE_DIRS})

set_target_properties(gdl PROPERTIES 
    OUTPUT_NAME gdl-${GDL_DLL_SUFFIX}
    ARCHIVE_OUTPUT_NAME gdl-${GDL_LIB_SUFFIX})

install(TARGETS gdl RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)

if(NOT GDL_SKIP_HEADERS)
    install(FILES
	    gdl/gdl.h
	    gdl/gdl-dock.h
	    gdl/gdl-dock-object.h
	    gdl/gdl-dock-master.h
	    gdl/gdl-dock-item.h
	    gdl/gdl-dock-item-grip.h
	    gdl/gdl-dock-layout.h
	    gdl/gdl-dock-bar.h
	    gdl/gdl-dock-placeholder.h
        DESTINATION include/gdl)
endif()

message(STATUS "Link-time dependencies:")
foreach(LIB ${GDL_REQUIRED_LIBRARIES})
    message(STATUS "  " ${LIB})
endforeach()
