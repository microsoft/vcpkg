cmake_minimum_required(VERSION 3.0)
project(openssl NONE)

include(vcpkg_execute_required_process)
set(SOURCE_PATH ${CMAKE_CURRENT_BINARY_DIR}/openssl-${OPENSSL_VERSION})

find_program(PERL perl)
find_program(NMAKE nmake)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    file(COPY ${OPENSSL_SOURCE_MASTER_COPY} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
else()
    file(COPY ${OPENSSL_SOURCE_MASTER_COPY} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
endif()

set(CONFIGURE_COMMAND ${PERL} Configure
    enable-static-engine
    enable-capieng
    no-asm
    no-ssl2
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
    list(APPEND CONFIGURE_COMMAND
        debug-${OPENSSL_ARCH}
        "--prefix=${OPENSSLDIR}"
        "--openssldir=${OPENSSLDIR}"
    )
else()
    set(OPENSSLDIR ${CURRENT_PACKAGES_DIR})
    list(APPEND CONFIGURE_COMMAND
        ${OPENSSL_ARCH}
        "--prefix=${OPENSSLDIR}"
        "--openssldir=${OPENSSLDIR}"
    )
endif()

vcpkg_execute_required_process(
    COMMAND ${CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME configure-perl-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)
vcpkg_execute_required_process(
    COMMAND ${OPENSSL_DO}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME configure-do-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)

if(BUILD_SHARED_LIBS)
    add_custom_command(OUTPUT ${OPENSSLDIR}/bin/ssleay32.dll ${OPENSSLDIR}/bin/libeay32.dll
        COMMAND ${NMAKE} -f ms\\ntdll.mak install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    add_custom_target(openssl ALL DEPENDS ${OPENSSLDIR}/bin/ssleay32.dll ${OPENSSLDIR}/bin/libeay32.dll)
else()
    add_custom_command(OUTPUT ${OPENSSLDIR}/bin/ssleay32.lib ${OPENSSLDIR}/bin/libeay32.lib
        COMMAND ${NMAKE} -f ms\\nt.mak install
        WORKING_DIRECTORY ${SOURCE_PATH}
    )
    add_custom_target(openssl ALL DEPENDS ${OPENSSLDIR}/bin/ssleay32.lib ${OPENSSLDIR}/bin/libeay32.lib)
endif()
