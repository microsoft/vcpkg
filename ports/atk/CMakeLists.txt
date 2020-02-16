cmake_minimum_required(VERSION 3.0)
project(atk C)

set(ATK_LIB_SUFFIX 1.0)
set(ATK_DLL_SUFFIX 1)
set(GLIB_LIB_VERSION 2.0)

if(BUILD_SHARED_LIBS)
    set(ATK_EXPORT_MACRO DLL_EXPORT)
endif()

# generate atkmarshal.c and atkmarshal.h source files
# glib-genmarshal should be installed along with glib
find_program(GLIB_GENMARSHAL glib-genmarshal PATH_SUFFIXES glib)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/atk)

message("Generating atkmarshal.h: ${GLIB_GENMARSHAL} --prefix=atk_marshal ${CMAKE_CURRENT_SOURCE_DIR}/atk/atkmarshal.list --header")
execute_process(
    COMMAND ${GLIB_GENMARSHAL} --prefix=atk_marshal ${CMAKE_CURRENT_SOURCE_DIR}/atk/atkmarshal.list --header
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/atk
    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/atk/atkmarshal.h
)

message("Generating atkmarshal.c: ${GLIB_GENMARSHAL} --prefix=atk_marshal ${CMAKE_CURRENT_SOURCE_DIR}/atk/atkmarshal.list --body")
execute_process(
    COMMAND ${GLIB_GENMARSHAL} --prefix=atk_marshal ${CMAKE_CURRENT_SOURCE_DIR}/atk/atkmarshal.list --body
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/atk
    OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/atk/atkmarshal.c
)

if (WIN32)
    configure_file(config.h.win32 ${CMAKE_CURRENT_BINARY_DIR}/config.h COPYONLY)
else()
    configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)
endif()
add_definitions(-DHAVE_CONFIG_H)
include_directories(. ./atk ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/atk)

find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_GLIB_LIBRARY glib-${GLIB_LIB_VERSION})
find_library(GLIB_GOBJECT_LIBRARY gobject-${GLIB_LIB_VERSION})
find_library(GLIB_GMODULE_LIBRARY gmodule-${GLIB_LIB_VERSION})
set(GLIB_LIBRARIES ${GLIB_GLIB_LIBRARY} ${GLIB_GOBJECT_LIBRARY} ${GLIB_GMODULE_LIBRARY})

if (WIN32 OR APPLE)
    find_path(LIBINTL_INCLUDE_DIR libintl.h)
    find_library(LIBINTL_LIBRARY NAMES libintl intl)
else()
    find_package(Intl REQUIRED)
    set(LIBINTL_INCLUDE_DIR ${Intl_INCLUDE_DIRS})
    set(LIBINTL_LIBRARY ${Intl_LIBRARIES})
endif()

set(ATK_SOURCES
    atk/atkaction.c
    atk/atkcomponent.c
    atk/atkdocument.c
    atk/atkeditabletext.c
    atk/atkgobjectaccessible.c
    atk/atkhyperlink.c
    atk/atkhyperlinkimpl.c
    atk/atkhypertext.c
    atk/atkimage.c
    atk/atknoopobject.c
    atk/atknoopobjectfactory.c
    atk/atkobject.c
    atk/atkobjectfactory.c
    atk/atkplug.c
    atk/atkprivate.c
    atk/atkrange.c
    atk/atkregistry.c
    atk/atkrelation.c
    atk/atkrelationset.c
    atk/atkselection.c
    atk/atksocket.c
    atk/atkstate.c
    atk/atkstateset.c
    atk/atkstreamablecontent.c
    atk/atktable.c
    atk/atktablecell.c
    atk/atktext.c
    atk/atkutil.c
    atk/atkmisc.c
    atk/atkvalue.c
    atk/atkversion.c
    atk/atkwindow.c
    atk/atk-enum-types.c)

add_library(atk ${ATK_SOURCES})
target_compile_definitions(atk PRIVATE ATK_COMPILATION ${ATK_EXPORT_MACRO} G_DISABLE_SINGLE_INCLUDES ATK_LOCALEDIR="/dummy/share/locale")
target_link_libraries(atk ${LIBINTL_LIBRARY} ${GLIB_LIBRARIES})
target_include_directories(atk PRIVATE ${GLIB_INCLUDE_DIR} ${LIBINTL_INCLUDE_DIR})

set_target_properties(atk PROPERTIES 
    OUTPUT_NAME atk-${ATK_DLL_SUFFIX}
    ARCHIVE_OUTPUT_NAME atk-${ATK_LIB_SUFFIX})

install(TARGETS atk RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)

if(NOT ATK_SKIP_HEADERS)
    install(FILES
        atk/atk.h
        atk/atkaction.h
        atk/atkcomponent.h
        atk/atkdocument.h
        atk/atkeditabletext.h
        atk/atkgobjectaccessible.h
        atk/atkhyperlink.h
        atk/atkhyperlinkimpl.h
        atk/atkhypertext.h
        atk/atknoopobject.h
        atk/atknoopobjectfactory.h
        atk/atkobject.h
        atk/atkobjectfactory.h
        atk/atkplug.h
        atk/atkimage.h
        atk/atkrange.h
        atk/atkregistry.h
        atk/atkrelation.h
        atk/atkrelationtype.h
        atk/atkrelationset.h
        atk/atkselection.h
        atk/atksocket.h
        atk/atkstate.h
        atk/atkstateset.h
        atk/atkstreamablecontent.h
        atk/atktable.h
        atk/atktablecell.h
        atk/atktext.h
        atk/atkutil.h
        atk/atkmisc.h
        atk/atkvalue.h
        atk/atkwindow.h
        atk/atkversion.h
        atk/atk-enum-types.h
        atk/atkversion.h
        DESTINATION include/atk)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${LIBINTL_LIBRARY})
foreach(GL ${GLIB_LIBRARIES})
    message(STATUS "  " ${GL})
endforeach()
