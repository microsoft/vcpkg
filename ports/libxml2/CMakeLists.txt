cmake_minimum_required(VERSION 3.8)
project(libxml2 C)

set(WITH_TRIO 0 CACHE BOOL "Add trio support")
set(WITH_THREADS 1 CACHE BOOL "Add multithread support")
set(WITH_THREAD_ALLOC 0 CACHE BOOL "Add per-thread memory")
set(WITH_TREE 1 CACHE BOOL "Add the DOM like tree manipulation APIs")
set(WITH_OUTPUT 1 CACHE BOOL "Add the serialization support")
set(WITH_PUSH 1 CACHE BOOL "Add the PUSH parser interfaces")
set(WITH_READER 1 CACHE BOOL "Add the xmlReader parsing interface")
set(WITH_PATTERN 1 CACHE BOOL "Add the xmlPattern selection interface")
set(WITH_WRITER 1 CACHE BOOL "Add the xmlWriter saving interface")
set(WITH_SAX1 1 CACHE BOOL "Add the older SAX1 interface")
set(WITH_VALID 1 CACHE BOOL "Add the DTD validation support")
set(WITH_HTML 1 CACHE BOOL "Add the HTML support")
set(WITH_LEGACY 1 CACHE BOOL "Add deprecated APIs for compatibility")
set(WITH_C14N 1 CACHE BOOL "Add the Canonicalization support")
set(WITH_CATALOG 1 CACHE BOOL "Add the Catalog support")
set(WITH_DOCB 1 CACHE BOOL "Add Docbook SGML support")
set(WITH_XPATH 1 CACHE BOOL "Add the XPATH support")
set(WITH_XPTR 1 CACHE BOOL "Add the XPointer support")
set(WITH_XINCLUDE 1 CACHE BOOL "Add the XInclude support")
set(WITH_ICONV 1 CACHE BOOL "Add ICONV support")
set(WITH_ICU 0 CACHE BOOL "Add ICU support")
set(WITH_ISO8859X 1 CACHE BOOL "Add ISO8859X support if no iconv")
set(WITH_DEBUG 1 CACHE BOOL "Add the memory debugging module")
set(WITH_MEM_DEBUG 0 CACHE BOOL "Add the memory debugging module")
set(WITH_RUN_DEBUG 0 CACHE BOOL "Add the runtime debugging module")
set(WITH_REGEXPS 1 CACHE BOOL "Add Regular Expressions support")
set(WITH_SCHEMAS 1 CACHE BOOL "Add Relax-NG and Schemas support")
set(WITH_SCHEMATRON 1 CACHE BOOL "Add Schematron support")
set(WITH_MODULES 1 CACHE BOOL "Add the dynamic modules support")
set(WITH_ZLIB 1 CACHE BOOL "Add zlib support")
set(WITH_LZMA 1 CACHE BOOL "Add liblzma support")
set(WITH_HTTP 1 CACHE BOOL "Add the HTTP support")
set(WITH_FTP 1 CACHE BOOL "Add the FTP support")

option(INSTALL_HEADERS "Install public header files" ON)

set(MODULE_EXTENSION ".so")

set(CMAKE_SHARED_LIBRARY_PREFIX)
set(CMAKE_STATIC_LIBRARY_PREFIX)

find_package(ZLIB REQUIRED)
find_package(LibLZMA REQUIRED)
find_package(Iconv REQUIRED)

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
get_property(LIBRARIES TARGET Iconv::Iconv PROPERTY INTERFACE_LINK_LIBRARIES)
if(LIBRARIES)
    set_property(TARGET Iconv::Iconv PROPERTY INTERFACE_LINK_LIBRARIES "")
    foreach(LIBRARY ${LIBRARIES})
        # Since `libc.so` has no SONAME, CMake maps e.g. `/usr/lib/x86_64-linux-gnu/libc.so` to `-llibc`.
        # This is not found: it should be mapped to `-lc`.
        if(LIBRARY MATCHES "/libc\\.so$")
            set_property(TARGET Iconv::Iconv APPEND PROPERTY INTERFACE_LINK_LIBRARIES "c")
        else()
            set_property(TARGET Iconv::Iconv APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${LIBRARY}")
        endif()
    endforeach()
endif()
target_link_libraries(libxml2 PRIVATE
    Iconv::Iconv
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
    target_sources(libxml2 PRIVATE win32/libxml2.rc)
    set_source_files_properties(win32/libxml2.rc PROPERTIES COMPILE_FLAGS "-DLIBXML_MAJOR_VERSION=${LIBXML_MAJOR_VERSION} -DLIBXML_MINOR_VERSION=${LIBXML_MINOR_VERSION} -DLIBXML_MICRO_VERSION=${LIBXML_MICRO_VERSION} -DLIBXML_DOTTED_VERSION=\\\"${VERSION}\\\"")
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

# pkgconfig
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix "\${prefix}")
set(libdir ${prefix}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${prefix}/${CMAKE_INSTALL_INCLUDEDIR})

configure_file(libxml-2.0.pc.in libxml-2.0.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/libxml-2.0.pc DESTINATION lib/pkgconfig)