cmake_minimum_required(VERSION 3.9)
project(openssl C)

if(NOT SOURCE_PATH)
    message(FATAL_ERROR "Requires SOURCE_PATH")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Android" OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(PLATFORM linux-x86_64)
    else()
        set(PLATFORM linux-generic32)
    endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(PLATFORM ios64-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(PLATFORM ios-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" OR
           VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(PLATFORM iossimulator-xcrun)
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    # disable that makes linkage error (e.g. require stderr usage)
    list(APPEND DISABLES no-stdio no-ui no-asm)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(PLATFORM darwin64-arm64-cc)
    else()
        set(PLATFORM darwin64-x86_64-cc)
    endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(PLATFORM BSD-generic64)
elseif(CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
    set(PLATFORM BSD-generic64)
elseif(MINGW)
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(PLATFORM mingw64)
    else()
        set(PLATFORM mingw)
    endif()
else()
    message(FATAL_ERROR "Unknown platform")
endif()

get_filename_component(COMPILER_ROOT "${CMAKE_C_COMPILER}" DIRECTORY)

message("CMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
message("COMPILER_ROOT=${COMPILER_ROOT}")
message("CMAKE_SYSROOT=${CMAKE_SYSROOT}")
message("CMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}")
message("CMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}")
message("CMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
message("CMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}")
message("CMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}")
message("CMAKE_INCLUDE_SYSTEM_FLAG_C=${CMAKE_INCLUDE_SYSTEM_FLAG_C}")
message("CMAKE_C_OSX_DEPLOYMENT_TARGET_FLAG=${CMAKE_C_OSX_DEPLOYMENT_TARGET_FLAG}")

set(CFLAGS "${CMAKE_C_FLAGS}")
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CFLAGS "-Wno-error=unused-command-line-argument ${CMAKE_C_FLAGS}")
endif()
if(CMAKE_C_COMPILER_TARGET AND CMAKE_C_COMPILE_OPTIONS_TARGET)
    set(CFLAGS "${CFLAGS} ${CMAKE_C_COMPILE_OPTIONS_TARGET}${CMAKE_C_COMPILER_TARGET}")
endif()
if(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN AND CMAKE_C_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN)
    set(CFLAGS "${CFLAGS} ${CMAKE_C_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN}")
endif()
if(CMAKE_SYSROOT AND CMAKE_C_COMPILE_OPTIONS_SYSROOT)
    set(CFLAGS "${CFLAGS} ${CMAKE_C_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
elseif(CMAKE_OSX_SYSROOT AND CMAKE_C_COMPILE_OPTIONS_SYSROOT)
    set(CFLAGS "${CFLAGS} ${CMAKE_C_COMPILE_OPTIONS_SYSROOT}${CMAKE_OSX_SYSROOT}")
endif()
if (CMAKE_OSX_DEPLOYMENT_TARGET AND CMAKE_C_OSX_DEPLOYMENT_TARGET_FLAG)
    set(CFLAGS "${CFLAGS} ${CMAKE_C_OSX_DEPLOYMENT_TARGET_FLAG}${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()

string(REGEX REPLACE "^ " "" CFLAGS "${CFLAGS}")

if(CMAKE_HOST_WIN32)
    file(TO_NATIVE_PATH ENV_PATH "${COMPILER_ROOT};$ENV{PATH}")
else()
    file(TO_NATIVE_PATH ENV_PATH "${COMPILER_ROOT}:$ENV{PATH}")
endif()
set(ENV{ANDROID_DEV} "${CMAKE_SYSROOT}/usr")
set(ENV{CC} "${CMAKE_C_COMPILER}")

message("ENV{ANDROID_DEV}=$ENV{ANDROID_DEV}")

get_filename_component(SOURCE_PATH_NAME "${SOURCE_PATH}" NAME)
set(BUILDDIR "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE_PATH_NAME}")

if(NOT EXISTS "${BUILDDIR}")
    file(COPY ${SOURCE_PATH} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endif()

get_filename_component(MSYS_BIN_DIR "${MAKE}" DIRECTORY)

if(BUILD_SHARED_LIBS)
    set(SHARED shared)
    file(STRINGS "${BUILDDIR}/include/openssl/opensslv.h" SHLIB_VERSION
        REGEX "^#[\t ]*define[\t ]+SHLIB_VERSION_NUMBER[\t ]+\".*\".*")
    string(REGEX REPLACE "^.*SHLIB_VERSION_NUMBER[\t ]+\"([^\"]*)\".*$" "\\1"
        SHLIB_VERSION "${SHLIB_VERSION}")
    if(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(LIB_EXT dylib)
        set(LIB_EXTS ${SHLIB_VERSION}.${LIB_EXT})
    elseif(VCPKG_TARGET_IS_MINGW)
        string(REPLACE "." "_" SHLIB_VERSION "${SHLIB_VERSION}")
        set(BIN_EXT dll)
        set(LIB_EXT dll.a)
    else()
        set(LIB_EXT so)
        set(LIB_EXTS ${LIB_EXT}.${SHLIB_VERSION})
    endif()
    list(APPEND BIN_EXTS ${BIN_EXT})
    list(APPEND LIB_EXTS ${LIB_EXT})
else()
    set(SHARED no-shared)
    set(LIB_EXTS a)
endif()
foreach(lib ssl crypto)
    foreach(ext ${LIB_EXTS})
        list(APPEND INSTALL_LIBS "${BUILDDIR}/lib${lib}.${ext}")
        list(APPEND INSTALL_PKG_CONFIGS "${BUILDDIR}/lib${lib}.pc")
    endforeach()
    foreach(ext ${BIN_EXTS})
    # This might be wrong for targets which don't follow this naming scheme, but I'm not aware of any
        if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
            list(APPEND INSTALL_BINS "${BUILDDIR}/lib${lib}-${SHLIB_VERSION}-x64.${ext}")
        else()
            list(APPEND INSTALL_BINS "${BUILDDIR}/lib${lib}-${SHLIB_VERSION}.${ext}")
        endif()
    endforeach()
endforeach()

if(CMAKE_HOST_WIN32)
    set(ENV_COMMAND set)
    set(PATH_VAR ";%PATH%")
else()
    set(ENV_COMMAND export)
    set(PATH_VAR ":$ENV{PATH}")
endif()



add_custom_command(
    OUTPUT "${BUILDDIR}/Makefile"
    COMMAND ${ENV_COMMAND} CC=${CMAKE_C_COMPILER}
    COMMAND ${ENV_COMMAND} AR=${CMAKE_AR}
    COMMAND ${ENV_COMMAND} LD=${CMAKE_LINKER}
    COMMAND ${ENV_COMMAND} RANLIB=${CMAKE_RANLIB}
    COMMAND ${ENV_COMMAND} MAKE=${MAKE}
    COMMAND ${ENV_COMMAND} MAKEDEPPROG=${CMAKE_C_COMPILER}
    COMMAND ${ENV_COMMAND} "PATH=${MSYS_BIN_DIR}${PATH_VAR}"
    COMMAND "${PERL}" Configure
        ${SHARED}
        enable-static-engine
        no-zlib
        no-ssl2
        no-idea
        no-bf
        no-cast
        no-seed
        no-md2
        no-tests
        ${DISABLES}
        ${PLATFORM}
        "--prefix=${CMAKE_INSTALL_PREFIX}"
        "--openssldir=/etc/ssl"
        ${CFLAGS}
    COMMAND "${CMAKE_COMMAND}" "-DDIR=${BUILDDIR}" -P "${CMAKE_CURRENT_LIST_DIR}/remove-deps.cmake"
    VERBATIM
    WORKING_DIRECTORY "${BUILDDIR}"
)

add_custom_target(build_libs ALL
    COMMAND ${ENV_COMMAND} "PATH=${MSYS_BIN_DIR}${PATH_VAR}"
    COMMAND "${CMAKE_COMMAND}" -E touch "${BUILDDIR}/krb5.h"
    COMMAND "${MAKE}" build_libs
    VERBATIM
    WORKING_DIRECTORY "${BUILDDIR}"
    DEPENDS "${BUILDDIR}/Makefile"
    BYPRODUCTS ${INSTALL_LIBS}
)

if((CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR CMAKE_SYSTEM_NAME STREQUAL "iOS") AND BUILD_SHARED_LIBS)
    if(DEFINED CMAKE_INSTALL_NAME_DIR)
        set(ID_PREFIX "${CMAKE_INSTALL_NAME_DIR}")
    else()
        set(ID_PREFIX "@rpath")
    endif()

    add_custom_command(
        TARGET build_libs
        COMMAND /usr/bin/install_name_tool -id "${ID_PREFIX}/libssl.${SHLIB_VERSION}.dylib"
                                               "${BUILDDIR}/libssl.${SHLIB_VERSION}.dylib"
        COMMAND /usr/bin/install_name_tool -id "${ID_PREFIX}/libcrypto.${SHLIB_VERSION}.dylib"
                                               "${BUILDDIR}/libcrypto.1.1.dylib"
        COMMAND /usr/bin/install_name_tool -change "${CMAKE_INSTALL_PREFIX}/lib/libcrypto.${SHLIB_VERSION}.dylib"
                                                   "${ID_PREFIX}/libcrypto.${SHLIB_VERSION}.dylib"
                                                   "${BUILDDIR}/libssl.${SHLIB_VERSION}.dylib"
        VERBATIM
    )
endif()

install(
    FILES ${INSTALL_LIBS}
    DESTINATION lib
)
install(
    FILES ${INSTALL_BINS}
    DESTINATION bin
)
install(
    FILES ${INSTALL_PKG_CONFIGS}
    DESTINATION lib/pkgconfig
)
