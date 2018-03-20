cmake_minimum_required(VERSION 3.8)
project(libxml2 C)

option(INSTALL_HEADERS "Install public header files" ON)

find_package(ZLIB REQUIRED)
find_package(LibLZMA REQUIRED)
if(WIN32)
    find_library(ICONV NAMES libiconv)
    find_library(ICONV_CHARSET NAMES libcharset)
endif()

set(SOURCES
    buf.c
    c14n.c
    catalog.c
    chvalid.c
    debugXML.c
    dict.c
    DOCBparser.c
    encoding.c
    entities.c
    error.c
    globals.c
    hash.c
    HTMLparser.c
    HTMLtree.c
    legacy.c
    list.c
    nanoftp.c
    nanohttp.c
    parser.c
    parserInternals.c
    pattern.c
    relaxng.c
    SAX.c
    SAX2.c
    schematron.c
    threads.c
    tree.c
    uri.c
    valid.c
    xinclude.c
    xlink.c
    xmlIO.c
    xmlmemory.c
    xmlreader.c
    xmlregexp.c
    xmlmodule.c
    xmlsave.c
    xmlschemas.c
    xmlschemastypes.c
    xmlstring.c
    xmlunicode.c
    xmlwriter.c
    xpath.c
    xpointer.c
    xzlib.c
)

# Generate xmlexports with fixed definition of LIBXML_STATIC
file(READ include/libxml/xmlexports.h XMLEXPORTS_H)
if(BUILD_SHARED_LIBS)
    string(REPLACE "!defined(LIBXML_STATIC)" "1" XMLEXPORTS_H "${XMLEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBXML_STATIC)" "0" XMLEXPORTS_H "${XMLEXPORTS_H}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/xmlexports.h "${XMLEXPORTS_H}")

file(GLOB PUBLIC_HEADERS include/libxml/*.h)
list(FILTER PUBLIC_HEADERS EXCLUDE REGEX "xmlexports\\.h$")
list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/xmlexports.h)

configure_file(include/win32config.h config.h COPYONLY)

add_library(libxml2 ${SOURCES})
if(INSTALL_HEADERS)
    set_target_properties(libxml2 PROPERTIES PUBLIC_HEADER "${PUBLIC_HEADERS}")
endif()
target_include_directories(libxml2 PRIVATE ${CMAKE_CURRENT_BINARY_DIR} win32/vc10 include ${LIBLZMA_INCLUDE_DIRS})
target_link_libraries(libxml2 PRIVATE
    ZLIB::ZLIB
    ${LIBLZMA_LIBRARIES}
)
if(WIN32)
    target_link_libraries(libxml2 PRIVATE
        ${ICONV}
        ${ICONV_CHARSET}
        wsock32.lib
        ws2_32.lib
    )
    target_compile_definitions(libxml2 PRIVATE
        -DHAVE_WIN32_THREADS
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
