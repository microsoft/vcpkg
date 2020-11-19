cmake_minimum_required(VERSION 3.9)
project(libxmlpp)

set(CMAKE_CXX_STANDARD 17)

find_path(GLIBMM_INCLUDE_DIR NAMES glibmm.h)
find_library(GLIBMM_LIBRARY NAMES glibmm)
find_library(GIOMM_LIBRARY NAMES giomm)
find_library(GLIB_LIBRARY NAMES glib glib-2.0)
find_library(GIO_LIBRARY NAMES gio gio-2.0)
find_library(GMODULE_LIBRARY NAMES gmodule gmodule-2.0)
find_library(GOBJECT_LIBRARY NAMES gobject gobject-2.0)
find_library(SIGCPP_LIBRARY NAMES sigc sigc-2.0)
find_library(FFI_LIBRARY NAMES ffi libffi)
find_library(PCRE_LIBRARY NAMES pcre libpcre)
find_package(LibXml2 REQUIRED)
find_package(LibLZMA REQUIRED)
find_package(ZLIB REQUIRED)

if(APPLE)
  find_library(LIBINTL_LIBRARY NAMES intl)
endif()

find_package(Iconv REQUIRED)
link_libraries(${LIBINTL_LIBRARY} Iconv::Iconv)

if(APPLE)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation)
  find_library(CORESERVICES_LIBRARY CoreServices)
  find_library(FOUNDATION_LIBRARY Foundation)
  link_libraries(${COREFOUNDATION_LIBRARY} ${CORESERVICES_LIBRARY} ${FOUNDATION_LIBRARY})
endif()

link_libraries(
    ${GIOMM_LIBRARY}
    ${GLIBMM_LIBRARY}
    ${GMODULE_LIBRARY}
    ${GOBJECT_LIBRARY}
    ${GIO_LIBRARY}
    ${GLIB_LIBRARY}
    ${SIGCPP_LIBRARY}
    ${FFI_LIBRARY}
    ${LIBXML2_LIBRARIES}
    ${PCRE_LIBRARY}
    ${LIBLZMA_LIBRARIES}
    ZLIB::ZLIB
)
include_directories(${GLIBMM_INCLUDE_DIR} ${LIBXML2_INCLUDE_DIRS} ${LIBLZMA_INCLUDE_DIRS})
include_directories(. ${CMAKE_BINARY_DIR}/config)
if(NOT WIN32)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
    link_libraries(Threads::Threads ${CMAKE_DL_LIBS})
endif()

# config file
if(WIN32)
    configure_file(MSVC_Net2010/libxml++/libxml++config.h ${CMAKE_BINARY_DIR}/config/libxml++config.h COPYONLY)
else()
    set(ENV{GLIBMM_CFLAGS} -I${GLIBMM_INCLUDE_DIR})
    set(ENV{GLIBMM_LIBS} "${GLIBMM_LIBRARY}")
    set(ENV{GIOMM_CFLAGS} -I${GLIBMM_INCLUDE_DIR})
    set(ENV{GIOMM_LIBS} "${GIOMM_LIBRARY}")
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

file(GLOB_RECURSE SOURCES libxml++/*.cc)
add_library(xml++ ${SOURCES})
target_compile_definitions(xml++ PRIVATE -DLIBXMLPP_BUILD)

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES ${CMAKE_BINARY_DIR}/config/libxml++config.h DESTINATION include)
    install(DIRECTORY libxml++ DESTINATION include FILES_MATCHING PATTERN *.h)
endif()
install(
    TARGETS xml++
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(NOT DISABLE_EXAMPLES)
    add_executable(dom_build examples/dom_build/main.cc)
    target_link_libraries(dom_build xml++)
endif()
