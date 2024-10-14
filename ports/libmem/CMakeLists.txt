cmake_minimum_required(VERSION 3.22.1)
cmake_policy(SET CMP0114 NEW)
cmake_policy(SET CMP0116 NEW)

# Enforce C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Disable incremental linking to resolve /Brepro incompatibility warning
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /INCREMENTAL:NO")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /INCREMENTAL:NO")

project(libmem LANGUAGES C CXX ASM)

# External dependencies: Capstone, Keystone, LLVM
find_package(PkgConfig REQUIRED)
pkg_check_modules(KEYSTONE REQUIRED keystone)
pkg_check_modules(CAPSTONE REQUIRED capstone)

# Find ZSTD
find_package(zstd REQUIRED CONFIG)

# Find LLVM
find_package(LLVM REQUIRED CONFIG)

# Include directories from Keystone, Capstone, Zstd, and LLVM
include_directories(${KEYSTONE_INCLUDE_DIRS})
include_directories(${CAPSTONE_INCLUDE_DIRS})
include_directories(${zstd_INCLUDE_DIRS})
include_directories(${LLVM_INCLUDE_DIRS})

# Ensure that all dependencies are found
if(NOT CAPSTONE_FOUND)
    message(FATAL_ERROR "Capstone not found! Please install Capstone.")
endif()

if(NOT KEYSTONE_FOUND)
    message(FATAL_ERROR "Keystone not found! Please install Keystone.")
endif()

if(NOT LLVM_FOUND)
    message(FATAL_ERROR "LLVM not found! Please ensure LLVM is installed.")
endif()

if(NOT zstd_FOUND)
    message(FATAL_ERROR "zstd not found! Please ensure zstd is installed.")
endif()

# Collect source files
set(LIBMEM_DIR "${PROJECT_SOURCE_DIR}")
set(LIBMEM_INC "${LIBMEM_DIR}/include")
set(INTERNAL_DIR "${LIBMEM_DIR}/internal")
set(COMMON_DIR "${LIBMEM_DIR}/src/common")

# OS-specific source files
if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    file(GLOB_RECURSE LIBMEM_SRC "${LIBMEM_DIR}/src/win/*.c" "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp" "${INTERNAL_DIR}/winutils/*.c" "${INTERNAL_DIR}/demangler/*.cpp")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    # Add Linux specific file patterns
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    # Add FreeBSD specific file patterns
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Add library target
if(LIBMEM_BUILD_STATIC)
    add_library(libmem STATIC ${LIBMEM_SRC})
else()
    add_library(libmem SHARED ${LIBMEM_SRC})
endif()

# Include LLVM in the project
target_include_directories(libmem PRIVATE "${LIBMEM_DIR}/src" "${INTERNAL_DIR}" "${COMMON_DIR}")

# Link dependencies (Keystone, Capstone, LLVM, Zstd)
target_link_libraries(libmem PRIVATE ${KEYSTONE_LIBRARIES} ${CAPSTONE_LIBRARIES} ${LLVM_LIBRARIES})

# Link Zstd based on platform
if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    target_link_libraries(libmem PRIVATE zstd::libzstd)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_SYSTEM_NAME} STREQUAL "Android")
    target_link_libraries(libmem PRIVATE zstd dl stdc++ m)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    target_link_libraries(libmem PRIVATE zstd dl kvm procstat elf stdc++ m)
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
install(DIRECTORY ${LIBMEM_INC}/libmem DESTINATION include)

# Handle runtime library selection for MSVC to avoid CRT linkage issues
#if(MSVC)
    #set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#endif()