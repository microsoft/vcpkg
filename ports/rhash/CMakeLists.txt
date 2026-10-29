cmake_minimum_required(VERSION 3.5)
project(rhash C)

# cf. configure: RHASH_XVERSION = $(printf "0x%02x%02x%02x%02x" "$_v1" "$_v2" "$_v3" 0)
set(RHASH_VERSION "undefined" CACHE STRING "")
if(NOT RHASH_VERSION MATCHES [[^([0-9]+)[.]([0-9]+)[.]([0-9]+)$]])
    message(FATAL_ERROR "Cannot derive RHASH_XVERSION from '${RHASH_VERSION}'")
endif()
MATH(EXPR RHASH_XVERSION "((${CMAKE_MATCH_1} * 256 + ${CMAKE_MATCH_2}) * 256 + ${CMAKE_MATCH_3}) * 256" OUTPUT_FORMAT HEXADECIMAL)

file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/Makefile RHASH_SOURCES REGEX "^SOURCES = .*$")
string(REPLACE "SOURCES = " "" RHASH_SOURCES "${RHASH_SOURCES}")
string(REPLACE " " ";" RHASH_SOURCES "${RHASH_SOURCES}")

add_library(rhash ${RHASH_SOURCES})

target_compile_definitions(rhash PRIVATE RHASH_XVERSION=${RHASH_XVERSION})

if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(rhash PRIVATE RHASH_EXPORTS)
endif()

target_include_directories(rhash INTERFACE $<INSTALL_INTERFACE:include>)

install(TARGETS rhash EXPORT unofficial-rhash-config
      RUNTIME DESTINATION bin
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-rhash-config
        FILE unofficial-rhash-config.cmake
        NAMESPACE unofficial::rhash::
        DESTINATION share/unofficial-rhash
)

if(NOT RHASH_SKIP_HEADERS)
    install(FILES rhash.h rhash_torrent.h DESTINATION include)
endif()

# cf. configure
set(LIBRHASH_PC "${CMAKE_CURRENT_BINARY_DIR}/librhash.pc")
file(WRITE "${LIBRHASH_PC}"
"prefix=fixup
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: librash
Description: LibRHash shared library
Version: ${RHASH_VERSION}
Cflags: -I\${includedir}
Libs: -L\${libdir} -lrhash
")

install(FILES "${LIBRHASH_PC}" DESTINATION "lib/pkgconfig")
