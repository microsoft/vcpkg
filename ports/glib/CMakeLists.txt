cmake_minimum_required(VERSION 3.0)
project(glib)

set(GLIB_VERSION 2.50.2)
set(GLIB_DLL_SUFFIX 2)
set(GLIB_LIB_SUFFIX 2.0)

if(CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-DG_ENABLE_DEBUG)
endif()

if(BUILD_SHARED_LIBS)
    set(GLIB_EXPORT_MACRO DLL_EXPORT)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# find dependencies

# zlib
find_package(ZLIB REQUIRED)
# pcre
find_path(PCRE_INCLUDE_DIR pcre.h)
if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(PCRE_SUFFIX d)
endif()
find_library(PCRE_LIBRARY pcre${PCRE_SUFFIX})
# libffi
find_path(FFI_INCLUDE_DIR ffi.h)
find_library(FFI_LIBRARY NAMES ffi libffi)
# libintl(gettext)
find_path(LIBINTL_INCLUDE_DIR libintl.h)
find_library(LIBINTL_LIBRARY NAMES intl libintl)

#prepare config files
configure_file(config.h.win32 ${CMAKE_SOURCE_DIR}/config.h COPYONLY)
configure_file(glib/glibconfig.h.win32 ${CMAKE_SOURCE_DIR}/glib/glibconfig.h COPYONLY)
configure_file(gmodule/gmoduleconf.h.win32 ${CMAKE_SOURCE_DIR}/gmodule/gmoduleconf.h COPYONLY)
configure_file(gio/gnetworking.h.win32 ${CMAKE_SOURCE_DIR}/gio/gnetworking.h COPYONLY)
add_definitions(-DHAVE_CONFIG_H)

include_directories(. ./glib)

# This macro purposely doesn't find nodes with sources that have additional properties set
# Most of such files in glib are PCRE sources which we don't use anyway
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

# main module
extract_vcproj_sources(build/win32/vs14/glib.vcxproj GLIB_SOURCES)
list(APPEND GLIB_SOURCES glib/libcharset/localcharset.c) # modified internal version with prefixed symbols
add_library(glib ${GLIB_SOURCES})
target_compile_definitions(glib PRIVATE USE_SYSTEM_PCRE ${GLIB_EXPORT_MACRO} GLIB_COMPILATION G_LOG_DOMAIN="GLib" LIBDIR)
target_link_libraries(glib ws2_32 winmm ${PCRE_LIBRARY} ${LIBINTL_LIBRARY})
target_include_directories(glib PRIVATE ${PCRE_INCLUDE_DIR})
target_include_directories(glib PUBLIC  ${LIBINTL_INCLUDE_DIR})
list(APPEND GLIB_TARGETS glib)

# gthread
add_library(gthread gthread/gthread-impl.c)
target_compile_definitions(gthread PRIVATE G_LOG_DOMAIN="GThread")
target_link_libraries(gthread glib ${LIBINTL_LIBRARY})
target_include_directories(gthread PRIVATE ${LIBINTL_INCLUDE_DIR})
list(APPEND GLIB_TARGETS gthread)

# gobject
extract_vcproj_sources(build/win32/vs14/gobject.vcxproj GOBJECT_SOURCES)
add_library(gobject ${GOBJECT_SOURCES})
target_compile_definitions(gobject PRIVATE GOBJECT_COMPILATION ${GLIB_EXPORT_MACRO} G_LOG_DOMAIN="GLib-GObject")
target_link_libraries(gobject gthread glib ${FFI_LIBRARY})
target_include_directories(gobject PRIVATE ${FFI_INCLUDE_DIR})
list(APPEND GLIB_TARGETS gobject)

# gmodule
add_library(gmodule gmodule/gmodule.c)
target_compile_definitions(gmodule PRIVATE G_LOG_DOMAIN="GModule")
target_link_libraries(gmodule glib ${LIBINTL_LIBRARY})
target_include_directories(gmodule PRIVATE ${LIBINTL_INCLUDE_DIR})
list(APPEND GLIB_TARGETS gmodule)

# gio
extract_vcproj_sources(build/win32/vs14/gio.vcxproj GIO_SOURCES)
add_library(gio ${GIO_SOURCES})
target_compile_definitions(gio PRIVATE GIO_COMPILATION ${GLIB_EXPORT_MACRO} G_LOG_DOMAIN="GLib-GIO")
target_link_libraries(gio glib gmodule gobject ws2_32 shlwapi dnsapi iphlpapi ${ZLIB_LIBRARIES})
target_include_directories(gio PRIVATE ./gio ./gmodule ${ZLIB_INCLUDE_DIRS})
list(APPEND GLIB_TARGETS gio)

foreach(GTARGET ${GLIB_TARGETS})
    set_target_properties(${GTARGET} PROPERTIES 
        OUTPUT_NAME ${GTARGET}-${GLIB_DLL_SUFFIX}
        ARCHIVE_OUTPUT_NAME ${GTARGET}-${GLIB_LIB_SUFFIX})
endforeach()

macro(add_glib_tool TOOL_NAME)
    add_executable(${TOOL_NAME} ${ARGN})
    target_link_libraries(${TOOL_NAME} glib)
    target_compile_definitions(${TOOL_NAME} PRIVATE GLIB_COMPILATION)
    list(APPEND GLIB_TOOLS ${TOOL_NAME})
endmacro()

macro(add_gio_tool TOOL_NAME)
    add_executable(${TOOL_NAME} ${ARGN})
    target_link_libraries(${TOOL_NAME} glib gio gobject gmodule)
    target_include_directories(${TOOL_NAME} PRIVATE ./gmodule ./gio)
    target_compile_definitions(${TOOL_NAME} PRIVATE GIO_COMPILATION)
    list(APPEND GLIB_TOOLS ${TOOL_NAME})
endmacro()

if(NOT GLIB_SKIP_TOOLS)
    configure_file(gobject/glib-mkenums.in ${CMAKE_SOURCE_DIR}/gobject/glib-mkenums @ONLY) # uses GLIB_VERSION
    install(FILES gobject/glib-mkenums DESTINATION tools/glib)
    
    add_gio_tool(gdbus gio/gdbus-tool.c)    
    add_gio_tool(gio-querymodules gio/gio-querymodules.c)
    file(GLOB GIO_TOOL_SOURCES gio/gio-tool*.c)
    add_gio_tool(gio-tool ${GIO_TOOL_SOURCES})
    set_target_properties(gio-tool PROPERTIES OUTPUT_NAME gio)
    add_gio_tool(glib-compile-resources gio/glib-compile-resources.c gio/gvdb/gvdb-builder.c)
    add_gio_tool(glib-compile-schemas gio/glib-compile-schemas.c gio/gvdb/gvdb-builder.c)   
    add_gio_tool(gresource gio/gresource-tool.c)
    add_gio_tool(gsettings gio/gsettings-tool.c)
    
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(WIN win32)
    else()
        set(WIN win64)
    endif()

    add_glib_tool(glib-genmarshal gobject/glib-genmarshal.c)
    add_glib_tool(gspawn-${WIN}-helper WIN32 glib/gspawn-win32-helper.c)
    add_glib_tool(gspawn-${WIN}-helper-console glib/gspawn-win32-helper-console.c)
    
    install(TARGETS ${GLIB_TOOLS} RUNTIME DESTINATION tools/glib)
endif()

install(TARGETS ${GLIB_TARGETS} RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
if(NOT GLIB_SKIP_HEADERS)
    include(install_headers)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${ZLIB_LIBRARIES})
message(STATUS "  " ${PCRE_LIBRARY})
message(STATUS "  " ${FFI_LIBRARY})
message(STATUS "  " ${LIBINTL_LIBRARY})
