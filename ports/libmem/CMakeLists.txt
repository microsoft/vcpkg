cmake_minimum_required(VERSION 3.22.1)
cmake_policy(SET CMP0114 NEW)
cmake_policy(SET CMP0116 NEW)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(libmem LANGUAGES C CXX ASM)

if (MSVC AND BUILD_SHARED_LIBS)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()
#if (MSVC AND NOT(BUILD_SHARED_LIBS))
if (MSVC)
    add_definitions(/DLM_EXPORT)
endif()
set(LIBMEM_ARCH ${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "Force a specific architecture")

find_package(PkgConfig REQUIRED)
pkg_check_modules(KEYSTONE REQUIRED keystone)
pkg_check_modules(CAPSTONE REQUIRED capstone)

find_package(LLVM REQUIRED CONFIG)

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

include(HandleLLVMOptions)

add_definitions(${LLVM_DEFINITIONS})

include_directories(${KEYSTONE_INCLUDE_DIRS})
include_directories(${CAPSTONE_INCLUDE_DIRS})
include_directories(${LLVM_INCLUDE_DIRS})

if(NOT CAPSTONE_FOUND)
    message(FATAL_ERROR "Capstone not found! Please install Capstone.")
endif()

if(NOT KEYSTONE_FOUND)
    message(FATAL_ERROR "Keystone not found! Please install Keystone.")
endif()

if(NOT LLVM_FOUND)
    message(FATAL_ERROR "LLVM not found! Please ensure LLVM is installed.")
endif()

set(LIBMEM_DIR "${PROJECT_SOURCE_DIR}")
set(LIBMEM_INC "${LIBMEM_DIR}/include")
set(INTERNAL_DIR "${LIBMEM_DIR}/internal")
set(COMMON_DIR "${LIBMEM_DIR}/src/common")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    file(GLOB_RECURSE LIBMEM_SRC "${LIBMEM_DIR}/src/win/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/winutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    if("${LIBMEM_ARCH}" STREQUAL "x86_64")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/linux/ptrace/x64/*.c")
    elseif("${LIBMEM_ARCH}" STREQUAL "i686" OR "${LIBMEM_ARCH}" STREQUAL "i386")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/linux/ptrace/x86/*.c")
    endif()
    file(GLOB LIBMEM_SRC ${LIBMEM_ARCH_SRC} "${LIBMEM_DIR}/src/linux/*.c" "${LIBMEM_DIR}/src/linux/ptrace/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD")
    if("${LIBMEM_ARCH}" STREQUAL "x86_64" OR "${LIBMEM_ARCH}" STREQUAL "amd64")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/freebsd/ptrace/x64/*.c")
    elseif("${LIBMEM_ARCH}" STREQUAL "i686" OR "${LIBMEM_ARCH}" STREQUAL "i386")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/freebsd/ptrace/x86/*.c")
    endif()
    file(GLOB LIBMEM_SRC ${LIBMEM_ARCH_SRC} "${LIBMEM_DIR}/src/freebsd/*.c" "${LIBMEM_DIR}/src/freebsd/ptrace/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

add_library(libmem ${LIBMEM_SRC})

target_compile_definitions(libmem PUBLIC LM_EXPORT)

target_include_directories(libmem PRIVATE "${LIBMEM_DIR}/src" "${INTERNAL_DIR}" "${COMMON_DIR}" "${LIBMEM_INC}")

llvm_map_components_to_libnames(llvm_libs Support Core Demangle)

target_link_libraries(libmem PRIVATE ${KEYSTONE_LIBRARIES} ${CAPSTONE_LIBRARIES} ${llvm_libs})

install(TARGETS libmem LIBRARY DESTINATION lib)
install(DIRECTORY ${LIBMEM_INC}/libmem DESTINATION include)
