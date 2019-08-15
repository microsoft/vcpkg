cmake_minimum_required(VERSION 3.8)
project(libxml2 C)

option(INSTALL_HEADERS "Install public header files" ON)

set(CMAKE_SHARED_LIBRARY_PREFIX)
set(CMAKE_STATIC_LIBRARY_PREFIX)

find_package(ZLIB REQUIRED)
find_package(LibLZMA REQUIRED)
find_package(unofficial-iconv REQUIRED)

file(GLOB SOURCES *.c)
list(FILTER SOURCES EXCLUDE REGEX "/(run|test|trio)[^/]*$")
list(FILTER SOURCES EXCLUDE REGEX "xml(lint|catalog).c$")
list(FILTER SOURCES EXCLUDE REGEX "rngparser\.c$")

# Generate xmlexports with fixed definition of LIBXML_STATIC
file(READ include/libxml/xmlexports.h XMLEXPORTS_H)
if(BUILD_SHARED_LIBS)
    string(REPLACE "!defined(LIBXML_STATIC)" "1" XMLEXPORTS_H "${XMLEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBXML_STATIC)" "0" XMLEXPORTS_H "${XMLEXPORTS_H}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/xmlexports.h "${XMLEXPORTS_H}")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    configure_file(include/win32config.h config.h COPYONLY)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    configure_file("${PORT_DIR}/config.osx.h" config.h COPYONLY)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    configure_file("${PORT_DIR}/config.linux.h" config.h COPYONLY)
else()
    message(FATAL_ERROR "No config.h checked in for the target platform. Please run ./configure for libxml2 and add the resulting config.h into this port.")
endif()

message(STATUS "Reading version info from configure.ac")

file(STRINGS "configure.ac"
    _libxml_version_defines REGEX "LIBXML_(MAJOR|MINOR|MICRO)_VERSION=([0-9]+)$")

foreach(ver ${_libxml_version_defines})
    if(ver MATCHES "LIBXML_(MAJOR|MINOR|MICRO)_VERSION=([0-9]+)$")
        set(LIBXML_${CMAKE_MATCH_1}_VERSION "${CMAKE_MATCH_2}" CACHE INTERNAL "")
    endif()
endforeach()

set(VERSION ${LIBXML_MAJOR_VERSION}.${LIBXML_MINOR_VERSION}.${LIBXML_MICRO_VERSION})
math(EXPR LIBXML_VERSION_NUMBER
    "${LIBXML_MAJOR_VERSION} * 10000 + ${LIBXML_MINOR_VERSION} * 100 + ${LIBXML_MICRO_VERSION}")

message(STATUS "LIBXML_MAJOR_VERSION: ${LIBXML_MAJOR_VERSION}")
message(STATUS "LIBXML_MINOR_VERSION: ${LIBXML_MINOR_VERSION}")
message(STATUS "LIBXML_MICRO_VERSION: ${LIBXML_MICRO_VERSION}")
message(STATUS "VERSION: ${VERSION}")
message(STATUS "LIBXML_VERSION_NUMBER: ${LIBXML_VERSION_NUMBER}")

set(WITH_TRIO 0)
set(WITH_THREADS 1)
set(WITH_THREAD_ALLOC 0)
set(WITH_TREE 1)
set(WITH_OUTPUT 1)
set(WITH_PUSH 1)
set(WITH_READER 1)
set(WITH_PATTERN 1)
set(WITH_WRITER 1)
set(WITH_SAX1 1)
set(WITH_FTP 1)
set(WITH_HTTP 1)
set(WITH_VALID 1)
set(WITH_HTML 1)
set(WITH_LEGACY 1)
set(WITH_C14N 1)
set(WITH_CATALOG 1)
set(WITH_DOCB 1)
set(WITH_XPATH 1)
set(WITH_XPTR 1)
set(WITH_XINCLUDE 1)
set(WITH_ICONV 1)
set(WITH_ICU 0)
set(WITH_ISO8859X 1)
set(WITH_DEBUG 1)
set(WITH_MEM_DEBUG 0)
set(WITH_RUN_DEBUG 0)
set(WITH_REGEXPS 1)
set(WITH_SCHEMAS 1)
set(WITH_SCHEMATRON 1)
set(WITH_MODULES 1)
set(MODULE_EXTENSION ".so")
set(WITH_ZLIB 1)
set(WITH_LZMA 1)

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(WITH_CATALOG 0)
    set(WITH_MODULES 0)
endif()

message(STATUS "Generating xmlversion.h")

configure_file(include/libxml/xmlversion.h.in include/libxml/xmlversion.h)

add_library(libxml2 ${SOURCES})
if(INSTALL_HEADERS)
    file(GLOB PUBLIC_HEADERS include/libxml/*.h ${CMAKE_CURRENT_BINARY_DIR}/include/libxml/xmlversion.h)
    list(FILTER PUBLIC_HEADERS EXCLUDE REGEX "xmlexports\\.h$")
    list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/xmlexports.h)

    set_target_properties(libxml2 PROPERTIES PUBLIC_HEADER "${PUBLIC_HEADERS}")
endif()
target_include_directories(libxml2 PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/include include ${LIBLZMA_INCLUDE_DIRS})
target_link_libraries(libxml2 PRIVATE
    unofficial::iconv::libcharset unofficial::iconv::libiconv
    ZLIB::ZLIB
    ${LIBLZMA_LIBRARIES}
)
if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    target_include_directories(libxml2 PRIVATE win32/vc10)
    target_link_libraries(libxml2 PRIVATE
        wsock32.lib
        ws2_32.lib
    )
    target_compile_definitions(libxml2 PRIVATE
        -DHAVE_WIN32_THREADS
        _WINSOCK_DEPRECATED_NO_WARNINGS
    )
endif()

target_compile_definitions(libxml2 PRIVATE
    -D_CRT_SECURE_NO_DEPRECATE
    -D_CRT_NONSTDC_NO_DEPRECATE
    -D_REENTRANT
    -DNOLIBTOOL
    -DHAVE_ZLIB_H
    -DHAVE_LZMA_H
)
if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(libxml2 PRIVATE -DLIBXML_STATIC)
endif()

set(TARGET_INSTALL_OPTIONS)
if(INSTALL_HEADERS)
    set(TARGET_INSTALL_OPTIONS PUBLIC_HEADER DESTINATION include/libxml)
endif()

install(TARGETS libxml2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    ${TARGET_INSTALL_OPTIONS}
)
