cmake_minimum_required(VERSION 3.0)
project(openssl NONE)

include(vcpkg_execute_required_process)

find_package(ZLIB REQUIRED)
find_program(PERL perl)
find_program(NMAKE nmake)

message(STATUS "Extracting source ${OPENSSL_SOURCE_ARCHIVE}")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E tar xjf ${OPENSSL_SOURCE_ARCHIVE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    LOGNAME extract-${TARGET_TRIPLET}-rel
)

set(CONFIGURE_COMMAND ${PERL} Configure
    no-idea
    no-mdc2
    no-rc5
    no-asm
    zlib-dynamic
    --with-zlib-include=${ZLIB_INCLUDE_DIRS}
)

if(TARGET_TRIPLET MATCHES "x86-windows")
    set(OPENSSL_ARCH VC-WIN32)
    set(OPENSSL_DO "ms\\do_ms.bat")
elseif(TARGET_TRIPLET MATCHES "x64")
    set(OPENSSL_ARCH VC-WIN64A)
    set(OPENSSL_DO "ms\\do_win64a.bat")
else()
    message(FATAL_ERROR "Unsupported target triplet: ${TARGET_TRIPLET}")
endif()

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(OPENSSLDIR ${CURRENT_PACKAGES_DIR}/debug)
    list(GET ZLIB_LIBRARIES -1 ZLIB_DEBUG_LIBRARY)
    list(APPEND CONFIGURE_COMMAND
        debug-${OPENSSL_ARCH}
        --openssldir=${OPENSSLDIR}
        --with-zlib-lib=${ZLIB_DEBUG_LIBRARY}
    )
else()
    set(OPENSSLDIR ${CURRENT_PACKAGES_DIR})
    list(APPEND CONFIGURE_COMMAND
        ${OPENSSL_ARCH}
        --openssldir=${OPENSSLDIR}
        --with-zlib-lib=${ZLIB_LIBRARIES}
    )
endif()

vcpkg_execute_required_process(
    COMMAND ${CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/openssl-${VERSION}
    LOGNAME configure-perl-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)
vcpkg_execute_required_process(
    COMMAND ${OPENSSL_DO}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/openssl-${VERSION}
    LOGNAME configure-do-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)

add_custom_command(OUTPUT ${OPENSSLDIR}/bin/ssleay32.dll ${OPENSSLDIR}/bin/libeay32.dll
    COMMAND ${NMAKE} -f ms\\ntdll.mak install
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/openssl-${VERSION}
)
add_custom_target(openssl ALL DEPENDS ${OPENSSLDIR}/bin/ssleay32.dll ${OPENSSLDIR}/bin/libeay32.dll)