cmake_minimum_required(VERSION 3.0)
project(gtk+ C)

configure_file(config.h.win32 ${CMAKE_CURRENT_SOURCE_DIR}/config.h COPYONLY)
configure_file(gdk/gdkconfig.h.win32_broadway ${CMAKE_CURRENT_SOURCE_DIR}/gdk/gdkconfig.h COPYONLY)

set(GLIB_LIB_SUFFIX 2.0)
set(PANGO_LIB_SUFFIX 1.0)
set(ATK_LIB_SUFFIX 1.0)
set(GDK_PIXBUF_LIB_SUFFIX 2.0)
if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(CAIRO_LIB_SUFFIX d)
endif()

if (WIN32)
  # Set utf-8 charset to avoid compile error C2001
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /utf-8")
endif()

# find dependencies
# glib
find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_GLIB_LIBRARY glib-${GLIB_LIB_SUFFIX})
find_library(GLIB_GIO_LIBRARY gio-${GLIB_LIB_SUFFIX})
find_library(GLIB_GMODULE_LIBRARY gmodule-${GLIB_LIB_SUFFIX})
find_library(GLIB_GOBJECT_LIBRARY gobject-${GLIB_LIB_SUFFIX})
set(GLIB_LIBRARIES ${GLIB_GLIB_LIBRARY} ${GLIB_GIO_LIBRARY} ${GLIB_GMODULE_LIBRARY} ${GLIB_GOBJECT_LIBRARY})

# pango
find_path(PANGO_INCLUDE_DIR pango/pango.h)
find_library(PANGO_LIBRARY pango-${PANGO_LIB_SUFFIX})
find_library(PANGO_CAIRO_LIBRARY pangocairo-${PANGO_LIB_SUFFIX})
find_library(PANGO_WIN32_LIBRARY pangowin32-${PANGO_LIB_SUFFIX})
set(PANGO_LIBRARIES ${PANGO_LIBRARY} ${PANGO_CAIRO_LIBRARY} ${PANGO_WIN32_LIBRARY})
# cairo
find_library(CAIRO_LIBRARY cairo${CAIRO_LIB_SUFFIX})
find_library(CAIRO_GOBJECT_LIBRARY cairo-gobject${CAIRO_LIB_SUFFIX})
set(CAIRO_LIBRARIES ${CAIRO_LIBRARY} ${CAIRO_GOBJECT_LIBRARY})
find_path(CAIRO_INCLUDE_DIR cairo.h)

# atk
find_path(ATK_INCLUDE_DIR atk/atk.h)
find_library(ATK_LIBRARY atk-${ATK_LIB_SUFFIX})

# gdk-pixbuf
find_path(GDK_PIXBUF_INCLUDE_DIR gdk-pixbuf/gdk-pixbuf.h)
find_library(GDK_PIXBUF_LIBRARY gdk_pixbuf-${GDK_PIXBUF_LIB_SUFFIX})

# epoxy
find_path(EPOXY_INCLUDE_DIR epoxy/common.h)
find_library(EPOXY_LIBRARY epoxy)

# gettext
find_path(LIBINTL_INCLUDE_DIR libintl.h)
find_library(LIBINTL_LIBRARY NAMES intl libintl)

set(GTK_REQUIRED_LIBRARIES
    ${LIBINTL_LIBRARY}
    ${EPOXY_LIBRARY}
    ${GLIB_LIBRARIES}
    ${CAIRO_LIBRARIES}
    ${PANGO_LIBRARIES}
    ${GDK_PIXBUF_LIBRARY}
    ${ATK_LIBRARY})

set(GTK_REQUIRED_INCLUDE_DIR
    ${LIBINTL_INCLUDE_DIR}
    ${EPOXY_INCLUDE_DIR}
    ${GLIB_INCLUDE_DIR}
    ${GDK_PIXBUF_INCLUDE_DIR}
    ${CAIRO_INCLUDE_DIR}
    ${PANGO_INCLUDE_DIR}
    ${ATK_INCLUDE_DIR})

# defines expected by all modules
add_definitions(
    -DHAVE_CONFIG_H
    -DG_DISABLE_SINGLE_INCLUDES
    -DATK_DISABLE_SINGLE_INCLUDES
    -DGDK_PIXBUF_DISABLE_SINGLE_INCLUDES
    -DGTK_DISABLE_SINGLE_INCLUDES
    -D_USE_MATH_DEFINES)

add_definitions(-DG_ENABLE_DEBUG)
if(CMAKE_BUILD_TYPE STREQUAL Debug)
	add_definitions(-DG_ENABLE_CONSISTENCY_CHECKS)
else()
	add_definitions(-DG_DISABLE_CAST_CHECKS)
endif()

macro(extract_vcproj_sources VC_PROJECT OUT_VAR)
    file(READ ${VC_PROJECT} ${VC_PROJECT}-CONTENTS)
    STRING(REPLACE "\n" ";" ${VC_PROJECT}-CONTENTS "${${VC_PROJECT}-CONTENTS}") # split by lines
    foreach(LINE ${${VC_PROJECT}-CONTENTS})
        if(LINE MATCHES "<ClCompile Include=\\\".*\\\" />")
            string(REPLACE "<ClCompile Include=\"..\\..\\..\\" "" LINE ${LINE})
            string(REPLACE "\" />" "" LINE ${LINE})
            string(STRIP ${LINE} LINE)
            file(TO_CMAKE_PATH ${LINE} LINE)
            list(APPEND ${OUT_VAR} ${LINE})
        endif()
    endforeach()
endmacro()

# build 'win32' gdk backend
extract_vcproj_sources(build/win32/vs14/gdk3-win32.vcxproj GDK_WIN32_SOURCES)
add_library(gdk-3-win32 STATIC ${GDK_WIN32_SOURCES})
target_compile_definitions(gdk-3-win32 PRIVATE 
    GDK_COMPILATION G_LOG_DOMAIN="Gdk" INSIDE_GDK_WIN32)
target_include_directories(gdk-3-win32 PRIVATE . ./gdk ./gdk/win32 ${GTK_REQUIRED_INCLUDE_DIR})

# build 'broadway' gdk backend
extract_vcproj_sources(build/win32/vs14/gdk3-broadway.vcxproj GDK_BROADWAY_SOURCES)
add_library(gdk-3-broadway STATIC ${GDK_BROADWAY_SOURCES})
target_compile_definitions(gdk-3-broadway PRIVATE 
    GDK_COMPILATION G_LOG_DOMAIN="Gdk")
target_include_directories(gdk-3-broadway PRIVATE . ./gdk ./gdk/broadway ${GTK_REQUIRED_INCLUDE_DIR})

macro(gtk_add_module MODULE_NAME)
    add_library(${MODULE_NAME} ${ARGN})
    target_include_directories(${MODULE_NAME} PRIVATE . ./gdk ./gtk ${GTK_REQUIRED_INCLUDE_DIR})
    target_link_libraries(${MODULE_NAME} ${GTK_REQUIRED_LIBRARIES})
    set_target_properties(${MODULE_NAME} PROPERTIES 
        ARCHIVE_OUTPUT_NAME ${MODULE_NAME}.0)
    install(TARGETS ${MODULE_NAME} RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
endmacro()

extract_vcproj_sources(build/win32/vs14/gdk-3.vcxproj GDK_SOURCES)
gtk_add_module(gdk-3 ${GDK_SOURCES})
target_compile_definitions(gdk-3 PRIVATE GDK_COMPILATION)
target_include_directories(gdk-3 PRIVATE ./gdk/win32 ./gdk/broadway)
target_link_libraries(gdk-3 gdk-3-win32 gdk-3-broadway winmm dwmapi setupapi imm32 ws2_32)

extract_vcproj_sources(build/win32/vs14/gtk-3.vcxproj GTK_SOURCES)
set_source_files_properties(gtk/inspector/visual.c PROPERTIES COMPILE_FLAGS "/FImath.h")
gtk_add_module(gtk-3 ${GTK_SOURCES})
target_compile_definitions(gtk-3 PRIVATE
    GTK_COMPILATION
    G_LOG_DOMAIN="Gtk"
    GTK_HOST="i686-pc"
    GTK_PRINT_BACKENDS="file"
    GTK_PRINT_BACKEND_ENABLE_UNSUPPORTED
    INCLUDE_IM_am_et
    INCLUDE_IM_cedilla
    INCLUDE_IM_cyrillic_translit
    INCLUDE_IM_ime
    INCLUDE_IM_inuktitut
    INCLUDE_IM_ipa
    INCLUDE_IM_multipress
    INCLUDE_IM_thai
    INCLUDE_IM_ti_er
    INCLUDE_IM_ti_et
    INCLUDE_IM_viqr
    GTK_LIBDIR="/dummy/lib"
    GTK_DATADIR="/dummy/share"
    GTK_DATA_PREFIX="/dummy"
    GTK_SYSCONFDIR="/dummy/etc"
    MULTIPRESS_CONFDIR="/dummy/etc/gtk-3.0"
    MULTIPRESS_LOCALEDIR="/dummy/share/locale"
    GTK_VERSION="${GTK_VERSION}/etc"
    GTK_BINARY_VERSION="3.0.0/etc"
    GDK_DISABLE_DEPRECATED
    ISOLATION_AWARE_ENABLED)
target_link_libraries(gtk-3 gdk-3 winspool comctl32 imm32)
target_compile_options(gtk-3 PRIVATE "/wd4828" PRIVATE "/wd4244" PRIVATE "/wd4305" PRIVATE "/wd4018")

extract_vcproj_sources(build/win32/vs14/gailutil-3.vcxproj GAILUTIL_SOURCES)
gtk_add_module(gailutil-3 ${GAILUTIL_SOURCES})
target_compile_definitions(gailutil-3 PRIVATE GTK_DISABLE_DEPRECATED GDK_DISABLE_DEPRECATED)
target_link_libraries(gailutil-3 gtk-3 gdk-3)
set_target_properties(gailutil-3 PROPERTIES
    LINK_FLAGS \"/DEF:${CMAKE_CURRENT_SOURCE_DIR}/libgail-util/gailutil.def\")

if(NOT GTK_SKIP_HEADERS)
    set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    include(install_headers)
endif()
