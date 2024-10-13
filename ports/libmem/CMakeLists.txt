cmake_minimum_required(VERSION 3.22.1)

# Enforce C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(libmem LANGUAGES C CXX ASM)

# External dependencies: Capstone, Keystone, LLVM
find_package(PkgConfig REQUIRED)
pkg_check_modules(KEYSTONE REQUIRED keystone)
pkg_check_modules(CAPSTONE REQUIRED capstone)

# Find LLVM
find_package(LLVM REQUIRED CONFIG)

# Include directories from Keystone, Capstone, and LLVM
include_directories(${KEYSTONE_INCLUDE_DIRS})
include_directories(${CAPSTONE_INCLUDE_DIRS})
include_directories(${LLVM_INCLUDE_DIRS})

# Make sure Capstone, Keystone, and LLVM are found
if(NOT CAPSTONE_FOUND)
    message(FATAL_ERROR "Capstone not found! Please install Capstone.")
else()
    message(STATUS "Capstone found: ${CAPSTONE_LIBRARIES}")
endif()

if(NOT KEYSTONE_FOUND)
    message(FATAL_ERROR "Keystone not found! Please install Keystone.")
else()
    message(STATUS "Keystone found: ${KEYSTONE_LIBRARIES}")
endif()

if(NOT LLVM_FOUND)
    message(FATAL_ERROR "LLVM not found! Please ensure LLVM is installed.")
else()
    message(STATUS "LLVM found: ${LLVM_INCLUDE_DIRS}")
endif()

# Collect source files
set(LIBMEM_DIR "${PROJECT_SOURCE_DIR}")
set(LIBMEM_INC "${LIBMEM_DIR}/include")
set(INTERNAL_DIR "${LIBMEM_DIR}/internal")
set(COMMON_DIR "${LIBMEM_DIR}/src/common")

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    file(GLOB_RECURSE LIBMEM_SRC "${LIBMEM_DIR}/src/win/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/winutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/linux/ptrace/x64/*.c")
    elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686" OR ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/linux/ptrace/x86/*.c")
    endif()
    file(GLOB LIBMEM_SRC ${LIBMEM_ARCH_SRC} "${LIBMEM_DIR}/src/linux/*.c" "${LIBMEM_DIR}/src/linux/ptrace/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64" OR ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "amd64")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/freebsd/ptrace/x64/*.c")
    elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686" OR ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
        set(LIBMEM_ARCH_SRC "${LIBMEM_DIR}/src/common/arch/x86.c" "${LIBMEM_DIR}/src/freebsd/ptrace/x86/*.c")
    endif()
    file(GLOB LIBMEM_SRC ${LIBMEM_ARCH_SRC} "${LIBMEM_DIR}/src/freebsd/*.c" "${LIBMEM_DIR}/src/freebsd/ptrace/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
endif()

# Add library target
if(LIBMEM_BUILD_STATIC)
    add_library(libmem STATIC ${LIBMEM_SRC})
else()
    add_library(libmem SHARED ${LIBMEM_SRC})
endif()

# Include LLVM in the project
target_include_directories(libmem PRIVATE "${LIBMEM_DIR}/src" "${INTERNAL_DIR}" "${COMMON_DIR}")
include_directories(${PROJECT_SOURCE_DIR} ${LIBMEM_INC} ${KEYSTONE_INCLUDE_DIRS} ${CAPSTONE_INCLUDE_DIRS} ${LLVM_INCLUDE_DIRS})

# Link dependencies (Keystone, Capstone, LLVM)
target_link_libraries(libmem PRIVATE ${KEYSTONE_LIBRARIES} ${CAPSTONE_LIBRARIES} ${LLVM_LIBRARIES})

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    target_link_libraries(libmem PRIVATE user32 psapi ntdll shell32)
    target_compile_definitions(libmem PUBLIC alloca=_alloca)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_SYSTEM_NAME} STREQUAL "Android")
    target_link_libraries(libmem PRIVATE dl stdc++ m)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    target_link_libraries(libmem PRIVATE dl kvm procstat elf stdc++ m)
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Optionally build tests
if(LIBMEM_BUILD_TESTS)
    set(TESTS_DIR "${PROJECT_SOURCE_DIR}/tests")
    add_subdirectory(${TESTS_DIR})
endif()

# Install rules
install(TARGETS libmem LIBRARY DESTINATION lib)
install(TARGETS libmem RUNTIME DESTINATION lib)
install(DIRECTORY ${LIBMEM_INC}/libmem DESTINATION include)