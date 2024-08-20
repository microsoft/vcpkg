cmake_minimum_required(VERSION 3.14)

project(turbobase64 C)
if (SOURCE_PATH)
    set(CMAKE_SOURCE_DIR ${SOURCE_PATH})
endif ()

#Copyright 2016-2020 Yandex LLC
# https://github.com/ClickHouse/ClickHouse/blob/master/contrib/base64-cmake/CMakeLists.txt
#
#Apache License
#Version 2.0, January 2004
#http://www.apache.org/licenses/
#Yandex code starts

SET(LIBRARY_DIR ${CMAKE_SOURCE_DIR})

add_library(base64_scalar OBJECT ${LIBRARY_DIR}/turbob64c.c ${LIBRARY_DIR}/turbob64d.c)
add_library(base64_ssse3 OBJECT ${LIBRARY_DIR}/turbob64sse.c) # This file also contains code for ARM NEON

if (ARCH_AMD64)
    add_library(base64_avx OBJECT ${LIBRARY_DIR}/turbob64sse.c) # This is not a mistake. One file is compiled twice.
    add_library(base64_avx2 OBJECT ${LIBRARY_DIR}/turbob64avx2.c)
endif ()

target_compile_options(base64_scalar PRIVATE -falign-loops)

if (ARCH_AMD64)
    target_compile_options(base64_ssse3 PRIVATE -mssse3 -falign-loops)
    target_compile_options(base64_avx PRIVATE -falign-loops -mavx)
    target_compile_options(base64_avx2 PRIVATE -falign-loops -mavx2)
else ()
    target_compile_options(base64_ssse3 PRIVATE -falign-loops)
endif ()

if (ARCH_AMD64)
    add_library(tb64
                $<TARGET_OBJECTS:base64_scalar>
                $<TARGET_OBJECTS:base64_ssse3>
                $<TARGET_OBJECTS:base64_avx>
                $<TARGET_OBJECTS:base64_avx2>)
else ()
    add_library(tb64
                $<TARGET_OBJECTS:base64_scalar>
                $<TARGET_OBJECTS:base64_ssse3>)
endif ()

# End of Yandex code

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

target_include_directories(tb64 PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        )

install(TARGETS tb64
        EXPORT unofficial-turbobase64-config
        )
install(FILES "${CMAKE_SOURCE_DIR}/turbob64.h" TYPE INCLUDE)

install(EXPORT unofficial-turbobase64-config
        DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-turbobase64"
        NAMESPACE unofficial::turbobase64::
        )