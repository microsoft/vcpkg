cmake_minimum_required(VERSION 3.9)
project(glibmm)

set(CMAKE_CXX_STANDARD 17)

find_path(GLIB_INCLUDE_DIR NAMES glib.h)
find_library(GLIB_LIBRARY NAMES glib-2.0)
find_library(GIO_LIBRARY NAMES gio-2.0)
find_library(GOBJECT_LIBRARY NAMES gobject-2.0)
find_library(GMODULE_LIBRARY NAMES gmodule-2.0)
find_library(GTHREAD_LIBRARY NAMES gthread-2.0)
find_program(GLIB_COMPILE_SCHEMAS NAMES glib-compile-schemas)
find_library(PCRE_LIBRARY NAMES pcre)
find_library(SIGC_LIBRARY NAMES sigc-2.0)
find_library(FFI_LIBRARY NAMES ffi libffi)

include_directories(${GLIB_INCLUDE_DIR})
link_libraries(
    ${GIO_LIBRARY}
    ${GOBJECT_LIBRARY}
    ${GMODULE_LIBRARY}
    ${GTHREAD_LIBRARY}
    ${GLIB_LIBRARY}
    ${PCRE_LIBRARY}
    ${SIGC_LIBRARY}
    ${FFI_LIBRARY}
)

if(APPLE)
  find_library(LIBINTL_LIBRARY NAMES intl)
endif()

find_package(unofficial-iconv REQUIRED)
link_libraries(${LIBINTL_LIBRARY} unofficial::iconv::libiconv)

if(APPLE)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation)
  find_library(CORESERVICES_LIBRARY CoreServices)
  find_library(FOUNDATION_LIBRARY Foundation)
  link_libraries(${COREFOUNDATION_LIBRARY} ${CORESERVICES_LIBRARY} ${FOUNDATION_LIBRARY})
endif()

# Activate workaround for exporting all symbols from Windows DLLs to mimic the 
# behavior on Linux, where dynamic libraries always export all symbols.
# The same approach was already used by the upstream MSVC build (see MSVC_NMake/gendef/gendef.cc)
if (WIN32)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
endif()

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DGLIBMM_STATIC_LIB -DGIOMM_STATIC_LIB)
endif()

if(WIN32)
    add_compile_options(/FI${WARNINGS_HEADER} -DSIZEOF_WCHAR_T=2)
else()
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
    link_libraries(Threads::Threads ${CMAKE_DL_LIBS})
endif()

if(WIN32)
    configure_file(MSVC_Net2013/giomm/giommconfig.h ${CMAKE_BINARY_DIR}/config/gio/giommconfig.h COPYONLY)
    configure_file(MSVC_Net2013/glibmm/glibmmconfig.h ${CMAKE_BINARY_DIR}/config/glib/glibmmconfig.h COPYONLY)
else()
    set(ENV{GLIB_COMPILE_SCHEMAS} "${GLIB_COMPILE_SCHEMAS}")
    set(ENV{GLIBMM_CFLAGS} -I${GLIB_INCLUDE_DIR})
    set(ENV{GLIBMM_LIBS} "${GLIB_LIBRARY}")
    set(ENV{GIOMM_CFLAGS} -I${GLIB_INCLUDE_DIR})
    set(ENV{GIOMM_LIBS} "${GIO_LIBRARY}")
    set(ENV{PKG_CONFIG} "echo")

    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/config)
    execute_process(
        COMMAND "${CMAKE_SOURCE_DIR}/configure"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/config
        RESULT_VARIABLE res
    )
    if(NOT res EQUAL 0)
        message(FATAL_ERROR "Configure failed.")
    endif()
endif()

file(GLOB GLIBMM_SOURCES glib/glibmm/*.cc)
add_library(glibmm ${GLIBMM_SOURCES})
target_compile_definitions(glibmm PRIVATE -DGLIBMM_BUILD)
target_include_directories(glibmm PUBLIC glib ${CMAKE_BINARY_DIR}/config/glib)

file(GLOB GIOMM_SOURCES gio/giomm/*.cc)
if(WIN32)
    list(FILTER GIOMM_SOURCES EXCLUDE REGEX "desktopappinfo.cc\$|/unix[^/]+.cc\$")
endif()
add_library(giomm ${GIOMM_SOURCES})
target_compile_definitions(giomm PRIVATE -DGIOMM_BUILD)
target_link_libraries(giomm PUBLIC glibmm)
target_include_directories(giomm PUBLIC gio ${CMAKE_BINARY_DIR}/config/gio)

install(
    TARGETS glibmm giomm
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(
        FILES
            ${CMAKE_BINARY_DIR}/config/gio/giommconfig.h
            gio/giomm.h
            ${CMAKE_BINARY_DIR}/config/glib/glibmmconfig.h
            glib/glibmm.h
        DESTINATION include
    )
    install(
        DIRECTORY gio/giomm glib/glibmm
        DESTINATION include
        FILES_MATCHING PATTERN *.h
    )
endif()

if(NOT DISABLE_EXAMPLES)
    add_executable(options examples/options/main.cc)
    target_link_libraries(options PRIVATE giomm)
endif()
