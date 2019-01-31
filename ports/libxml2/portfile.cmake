include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF v2.9.9
    SHA512 bfcc08bd033f538a968205f0f9e2da4c3438ec2f35f017289783903365e13ed93d83f2f63c7497344a362b7418170ee586a5ecb45493e30feaa0f62b22a57b54
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

# Generate xmlversion.h

# TODO: Read version number from `configure.ac`.
set(VERSION 2.9.9)
set(LIBXML_VERSION_NUMBER 20909)

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

configure_file(
    ${SOURCE_PATH}/include/libxml/xmlversion.h.in
    ${SOURCE_PATH}/include/libxml/xmlversion.h)

vcpkg_install_cmake()

# Handle copyright
configure_file(${SOURCE_PATH}/Copyright ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxml2)
endif()
