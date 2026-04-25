cmake_minimum_required (VERSION 3.8)

message(STATUS "Reading version info from configure.ac")
file(STRINGS "configure.ac" _xmlsec_ac_init REGEX "^AC_INIT\\(")
if(_xmlsec_ac_init MATCHES "AC_INIT\\(\\[[^]]+\\],\\[([0-9]+\\.[0-9]+\\.[0-9]+)\\]")
    set(XMLSEC_VERSION "${CMAKE_MATCH_1}")
else()
    message(FATAL_ERROR "Could not parse version from configure.ac")
endif()

project(xmlsec1 VERSION ${XMLSEC_VERSION} LANGUAGES C CXX) # CXX needed when libxml2 is built with icu


include(CMakeDependentOption)
include(GNUInstallDirs)

option(INSTALL_HEADERS "Install headers" ON)
cmake_dependent_option(BUILD_WITH_DYNAMIC_LOADING "Enable dynamic loading of xmlsec-crypto libraries" OFF BUILD_SHARED_LIBS OFF)
option(BUILD_WITH_TOOLS "Build tools" ON)

find_package(LibXml2 REQUIRED)
find_package(OpenSSL REQUIRED)

FILE(GLOB SOURCESXMLSEC
    src/*.c
)

FILE(GLOB SOURCESXMLSECOPENSSL
    src/openssl/*.c
    src/strings.c
)

set(XMLSEC_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(XMLSEC_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(XMLSEC_VERSION_SUBMINOR "${PROJECT_VERSION_PATCH}")
math(EXPR _xmlsec_version_current "10000 * ${PROJECT_VERSION_MAJOR} + 100 * ${PROJECT_VERSION_MINOR} + ${PROJECT_VERSION_PATCH}")
set(XMLSEC_VERSION_INFO "${_xmlsec_version_current}:0:0")
message(STATUS "XMLSEC_VERSION: ${XMLSEC_VERSION}")
message(STATUS "XMLSEC_VERSION_MAJOR: ${XMLSEC_VERSION_MAJOR}")
message(STATUS "XMLSEC_VERSION_MINOR: ${XMLSEC_VERSION_MINOR}")
message(STATUS "XMLSEC_VERSION_SUBMINOR: ${XMLSEC_VERSION_SUBMINOR}")
message(STATUS "XMLSEC_VERSION_INFO: ${XMLSEC_VERSION_INFO}")

message(STATUS "Generating version.h")
configure_file(include/xmlsec/version.h.in include/xmlsec/version.h)
# Generate xmlexports with fixed definition of XMLSEC_STATIC
file(READ include/xmlsec/exports.h EXPORTS_H)
if(BUILD_SHARED_LIBS)
    string(REPLACE "!defined(XMLSEC_STATIC)" "1" EXPORTS_H "${EXPORTS_H}")
else()
    string(REPLACE "!defined(XMLSEC_STATIC)" "0" EXPORTS_H "${EXPORTS_H}")
endif()
set(EXPORTS_H "${EXPORTS_H}
#ifndef XMLSEC_NO_XSLT
#define XMLSEC_NO_XSLT 1
#endif
#ifndef XMLSEC_CRYPTO_OPENSSL
#define XMLSEC_CRYPTO_OPENSSL 1
#endif
#ifndef XMLSEC_NO_FTP
#define XMLSEC_NO_FTP 1
#endif
#ifndef XMLSEC_NO_HTTP
#define XMLSEC_NO_HTTP 1
#endif
#ifndef XMLSEC_NO_MD5
#define XMLSEC_NO_MD5 1
#endif
#ifndef XMLSEC_NO_RIPEMD160
#define XMLSEC_NO_RIPEMD160 1
#endif
#ifndef XMLSEC_NO_GOST
#define XMLSEC_NO_GOST 1
#endif
#ifndef XMLSEC_NO_GOST2012
#define XMLSEC_NO_GOST2012 1
#endif
#ifndef XMLSEC_NO_MLDSA
#define XMLSEC_NO_MLDSA 1
#endif
#ifndef XMLSEC_NO_SLHDSA
#define XMLSEC_NO_SLHDSA 1
#endif
")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/include/xmlsec/exports.h "${EXPORTS_H}")

if(MSVC)
    add_compile_options(/wd4130 /wd4127 /wd4152)
endif()

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")

add_library(xmlsec1 ${SOURCESXMLSEC})
add_library(xmlsec1-openssl ${SOURCESXMLSECOPENSSL})

target_include_directories(xmlsec1 PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(xmlsec1 PUBLIC LibXml2::LibXml2)
target_link_libraries(xmlsec1-openssl PUBLIC xmlsec1 OpenSSL::Crypto)

add_compile_definitions(
    PACKAGE="xmlsec1"
    XMLSEC_DEFAULT_CRYPTO="openssl"
    UNICODE
    _UNICODE
    _MBCS
    _REENTRANT
    WIN32_LEAN_AND_MEAN
)

set_target_properties(xmlsec1 xmlsec1-openssl PROPERTIES VERSION ${XMLSEC_VERSION_MAJOR}.${XMLSEC_VERSION_MINOR})

set(XMLSEC_CORE_CFLAGS XMLSEC_NO_XSLT XMLSEC_CRYPTO_OPENSSL XMLSEC_NO_FTP XMLSEC_NO_HTTP)
if(NOT BUILD_SHARED_LIBS)
    list(APPEND XMLSEC_CORE_CFLAGS XMLSEC_STATIC)
endif()
set(XMLSEC_OPENSSL_CFLAGS XMLSEC_NO_MD5 XMLSEC_NO_RIPEMD160 XMLSEC_NO_GOST XMLSEC_NO_GOST2012 XMLSEC_NO_MLDSA XMLSEC_NO_SLHDSA)

if(BUILD_WITH_DYNAMIC_LOADING)
    if(NOT WIN32)
        find_path(LTDL_INCLUDE_DIR NAMES ltdl.h)
        find_library(LTDL_LIBRARY NAMES ltdl)

        if(NOT LTDL_INCLUDE_DIR OR NOT LTDL_LIBRARY)
            message(FATAL_ERROR "libltdl not found (headers or library missing)")
        endif()

        target_include_directories(xmlsec1 PRIVATE ${LTDL_INCLUDE_DIR})
        target_link_libraries(xmlsec1 PRIVATE ${LTDL_LIBRARY})
    endif()
    list(APPEND XMLSEC_CORE_CFLAGS XMLSEC_CRYPTO_DYNAMIC_LOADING)
else()
    list(APPEND XMLSEC_CORE_CFLAGS XMLSEC_NO_CRYPTO_DYNAMIC_LOADING)
endif()

target_compile_definitions(xmlsec1
    PRIVATE $<IF:$<PLATFORM_ID:Windows>,XMLSEC_DL_WIN32,XMLSEC_DL_LIBLTDL>
    PUBLIC ${XMLSEC_CORE_CFLAGS}
)
target_compile_definitions(xmlsec1-openssl PUBLIC ${XMLSEC_OPENSSL_CFLAGS})

install(TARGETS xmlsec1 xmlsec1-openssl
    EXPORT unofficial-xmlsec-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-xmlsec-targets
    NAMESPACE unofficial::xmlsec::
    DESTINATION share/unofficial-xmlsec
)

if(INSTALL_HEADERS)
    install(DIRECTORY include/xmlsec DESTINATION include FILES_MATCHING PATTERN "*.h")
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/xmlsec DESTINATION include)
endif()

if(BUILD_WITH_TOOLS)
    # xmlsec application
    add_executable(xmlsec
        apps/crypto.c
        apps/cmdline.c
        apps/xmlsec.c)

    if(WIN32)
        target_link_libraries(xmlsec PRIVATE crypt32.lib)
    endif()

    target_link_libraries(xmlsec PRIVATE xmlsec1-openssl)

    if(NOT BUILD_SHARED_LIBS)
        # needed when libxml2 is built with icu
        find_package(Threads REQUIRED)
        target_link_libraries(xmlsec PRIVATE Threads::Threads)
    endif()
    install(TARGETS xmlsec DESTINATION tools/xmlsec)
endif()

message(STATUS "Generating pkgconfig files")

set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${prefix})
set(libdir ${prefix}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${prefix}/${CMAKE_INSTALL_INCLUDEDIR})
set(VERSION ${XMLSEC_VERSION})
set(LIBXML_MIN_VERSION ${LIBXML2_VERSION_STRING})
list(JOIN XMLSEC_CORE_CFLAGS " -D" XMLSEC_CORE_CFLAGS)
set(XMLSEC_CORE_CFLAGS "-D${XMLSEC_CORE_CFLAGS} -I\${includedir}/xmlsec1")
set(XMLSEC_CORE_LIBS "-lxmlsec1")
list(JOIN XMLSEC_OPENSSL_CFLAGS " -D" XMLSEC_OPENSSL_CFLAGS)
set(XMLSEC_OPENSSL_CFLAGS "${XMLSEC_CORE_CFLAGS} -D${XMLSEC_OPENSSL_CFLAGS}")
set(XMLSEC_OPENSSL_LIBS "-L\${libdir} -lxmlsec1-openssl ${XMLSEC_CORE_LIBS} -lcrypto")

configure_file(${PROJECT_SOURCE_DIR}/xmlsec.pc.in ${PROJECT_BINARY_DIR}/xmlsec1.pc @ONLY)
configure_file(${PROJECT_SOURCE_DIR}/xmlsec-openssl.pc.in ${PROJECT_BINARY_DIR}/xmlsec1-openssl.pc @ONLY)
install(FILES ${PROJECT_BINARY_DIR}/xmlsec1.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig/)
install(FILES ${PROJECT_BINARY_DIR}/xmlsec1-openssl.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig/)
