cmake_minimum_required (VERSION 3.8)
project (xmlsec1 C)

option(INSTALL_HEADERS_TOOLS "Install public header files and tools" ON)

find_package(LibXml2 REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Iconv REQUIRED)

FILE(GLOB SOURCESXMLSEC
	src/*.c
)

FILE(GLOB SOURCESXMLSECOPENSSL
	src/openssl/*.c
	src/strings.c
)

# Generate xmlexports with fixed definition of XMLSEC_STATIC
file(READ include/xmlsec/exports.h EXPORTS_H)
if(BUILD_SHARED_LIBS)
    string(REPLACE "!defined(XMLSEC_STATIC)" "1" EXPORTS_H "${EXPORTS_H}")
else()
    string(REPLACE "!defined(XMLSEC_STATIC)" "0" EXPORTS_H "${EXPORTS_H}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/exports.h "${EXPORTS_H}")

message(STATUS "Reading version info from configure.ac")

file(STRINGS "configure.ac"
    _xmlsec_version_defines REGEX "XMLSEC_VERSION_(MAJOR|MINOR|SUBMINOR)=([0-9]+)$")

foreach(ver ${_xmlsec_version_defines})
    if(ver MATCHES "XMLSEC_VERSION_(MAJOR|MINOR|SUBMINOR)=([0-9]+)$")
        set(XMLSEC_VERSION_${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" CACHE INTERNAL "")
    endif()
endforeach()

set(XMLSEC_VERSION ${XMLSEC_VERSION_MAJOR}.${XMLSEC_VERSION_MINOR}.${XMLSEC_VERSION_SUBMINOR})
math(EXPR XMLSEC_VERSION_INFO_NUMBER
	"${XMLSEC_VERSION_MAJOR} + ${XMLSEC_VERSION_MINOR}")
set(XMLSEC_VERSION_INFO ${XMLSEC_VERSION_INFO_NUMBER}:${XMLSEC_VERSION_SUBMINOR}:${XMLSEC_VERSION_MINOR})

message(STATUS "XMLSEC_VERSION: ${XMLSEC_VERSION}")
message(STATUS "XMLSEC_VERSION_MAJOR: ${XMLSEC_VERSION_MAJOR}")
message(STATUS "XMLSEC_VERSION_MINOR: ${XMLSEC_VERSION_MINOR}")
message(STATUS "XMLSEC_VERSION_SUBMINOR: ${XMLSEC_VERSION_SUBMINOR}")
message(STATUS "XMLSEC_VERSION_INFO: ${XMLSEC_VERSION_INFO}")

message(STATUS "Generating version.h")

configure_file(include/xmlsec/version.h.in include/xmlsec/version.h)

if(MSVC)
  add_compile_options(/wd4130 /wd4127 /wd4152)
endif()

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")

add_library(xmlsec1 ${SOURCESXMLSEC})
add_library(xmlsec1-openssl ${SOURCESXMLSECOPENSSL})

include_directories(${CMAKE_CURRENT_BINARY_DIR}/include include ${LIBXML2_INCLUDE_DIRS})

target_link_libraries(xmlsec1 PRIVATE
    ${LIBXML2_LIBRARIES} OpenSSL::SSL
)
target_link_libraries(xmlsec1-openssl PRIVATE
    ${LIBXML2_LIBRARIES} OpenSSL::SSL xmlsec1
)

add_compile_definitions(inline=__inline)
add_compile_definitions(PACKAGE="xmlsec1")
add_compile_definitions(XMLSEC_MSCRYPTO_NT4=1)
add_compile_definitions(HAVE_STDIO_H)
add_compile_definitions(HAVE_STDLIB_H)
add_compile_definitions(HAVE_STRING_H)
add_compile_definitions(HAVE_CTYPE_H)
add_compile_definitions(HAVE_MALLOC_H)
add_compile_definitions(HAVE_MEMORY_H)
add_compile_definitions(XMLSEC_NO_XSLT=1)
add_compile_definitions(XMLSEC_DEFAULT_CRYPTO="openssl")
add_compile_definitions(XMLSEC_NO_GOST)
add_compile_definitions(XMLSEC_NO_GOST2012)
add_compile_definitions(XMLSEC_NO_SIZE_T)
add_compile_definitions(UNICODE)
add_compile_definitions(_UNICODE)
add_compile_definitions(_MBCS)
add_compile_definitions(_REENTRANT)

target_compile_definitions(xmlsec1-openssl PRIVATE
    -DXMLSEC_CRYPTO_OPENSSL
)

set_target_properties(xmlsec1 PROPERTIES VERSION ${XMLSEC_VERSION_MAJOR}.${XMLSEC_VERSION_MINOR})
set_target_properties(xmlsec1-openssl PROPERTIES VERSION ${XMLSEC_VERSION_MAJOR}.${XMLSEC_VERSION_MINOR})

if(NOT BUILD_SHARED_LIBS)
    set(XMLSEC_CORE_CFLAGS "-DLIBXML_STATIC -DLIBXSLT_STATIC -DXMLSEC_STATIC -DXMLSEC_NO_CRYPTO_DYNAMIC_LOADING")
    set(XMLSEC_OPENSSL_CFLAGS ${XMLSEC_CORE_CFLAGS})
else()
    set(XMLSEC_CORE_CFLAGS "-DXMLSEC_DL_WIN32")
    set(XMLSEC_OPENSSL_CFLAGS ${XMLSEC_CORE_CFLAGS})
endif()

target_compile_definitions(xmlsec1 PRIVATE ${XMLSEC_CORE_CFLAGS})
target_compile_definitions(xmlsec1-openssl PRIVATE ${XMLSEC_OPENSSL_CFLAGS})

install(TARGETS xmlsec1 xmlsec1-openssl
    EXPORT xmlsecExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT xmlsecExport
    FILE unofficial-xmlsec-config.cmake
    NAMESPACE unofficial::xmlsec::
    DESTINATION share/unofficial-xmlsec
)

if(INSTALL_HEADERS_TOOLS)
	file(GLOB PUBLIC_HEADERS
		include/xmlsec/*.h
		include/xmlsec/openssl/*.h)
    list(FILTER PUBLIC_HEADERS EXCLUDE REGEX "exports\\.h$")

	foreach(file IN LISTS PUBLIC_HEADERS)
		get_filename_component(dir ${file} DIRECTORY)
		file(RELATIVE_PATH rel_dir ${CMAKE_SOURCE_DIR}/xmlsec/${LIB} ${dir})
		install(FILES ${file} DESTINATION "include/${rel_dir}")
	endforeach()

	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/xmlsec/version.h DESTINATION "include/xmlsec")
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/exports.h DESTINATION "include/xmlsec")

	# xmlsec application
	add_executable(xmlsec
		apps/crypto.c
		apps/cmdline.c
		apps/xmlsec.c)

	if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
		target_link_libraries(xmlsec PRIVATE crypt32.lib)
	endif()

	target_link_libraries(xmlsec PRIVATE
		${LIBXML2_LIBRARIES} OpenSSL::SSL xmlsec1 xmlsec1-openssl
	)
    if(NOT Iconv_IS_BUILT_IN)
        target_link_libraries(xmlsec PRIVATE Iconv::Iconv)
    endif()
    
	target_compile_definitions(xmlsec PRIVATE
		-DXMLSEC_CRYPTO_OPENSSL
	)

	if(BUILD_SHARED_LIBS)
		target_compile_definitions(xmlsec PRIVATE -DXMLSEC_CRYPTO_DYNAMIC_LOADING)
	else()
        find_package(Threads REQUIRED)
		target_compile_definitions(xmlsec PRIVATE -DLIBXML_STATIC -DLIBXSLT_STATIC -DXMLSEC_STATIC)
        target_link_libraries(xmlsec PUBLIC Threads::Threads)
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
set(OPENSSL_LIBS "-lssl -lcrypto")
set(XMLSEC_CORE_CFLAGS "${XMLSEC_CORE_CFLAGS} -DXMLSEC_DL_LIBLTDL=1 -I\${includedir}/xmlsec1 -DXMLSEC_CRYPTO_OPENSSL=1")
set(XMLSEC_CORE_LIBS "-lxmlsec1 -lltdl")
set(XMLSEC_OPENSSL_CFLAGS "${XMLSEC_OPENSSL_CFLAGS} -I\${includedir}/xmlsec1")
set(XMLSEC_OPENSSL_LIBS "-L\${libdir} -lxmlsec1-openssl ${XMLSEC_CORE_LIBS} ${OPENSSL_LIBS}")

configure_file(${PROJECT_SOURCE_DIR}/xmlsec.pc.in ${PROJECT_BINARY_DIR}/xmlsec1.pc @ONLY)
configure_file(${PROJECT_SOURCE_DIR}/xmlsec-openssl.pc.in ${PROJECT_BINARY_DIR}/xmlsec1-openssl.pc @ONLY)
install(FILES ${PROJECT_BINARY_DIR}/xmlsec1.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig/)
install(FILES ${PROJECT_BINARY_DIR}/xmlsec1-openssl.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig/)
