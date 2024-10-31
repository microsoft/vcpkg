cmake_minimum_required(VERSION 3.22.1)
cmake_policy(SET CMP0114 NEW)
cmake_policy(SET CMP0116 NEW)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(targets_export_name unofficial-libmem-target)

project(libmem LANGUAGES C CXX ASM)

if (MSVC AND BUILD_SHARED_LIBS)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

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

# Create the target without a namespace
add_library(libmem ${LIBMEM_SRC})

# Apply compile definitions, include directories, and link libraries to the target
target_compile_definitions(libmem PUBLIC LM_EXPORT)

target_include_directories(libmem PRIVATE "${LIBMEM_DIR}/src" "${INTERNAL_DIR}" "${COMMON_DIR}" "${LIBMEM_INC}")

# Overwrite PreLoad.cmake with an empty string
file(WRITE "${LIBMEM_DIR}/PreLoad.cmake" "")

llvm_map_components_to_libnames(llvm_libs Support Core Demangle)

target_link_libraries(libmem PRIVATE ${KEYSTONE_LIBRARIES} ${CAPSTONE_LIBRARIES} ${llvm_libs})

# Install the libmem library with proper namespacing
install(TARGETS libmem
    EXPORT ${targets_export_name}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Install the export file, which allows users to find the target
install(EXPORT ${targets_export_name}
    NAMESPACE unofficial::libmem::
    FILE ${targets_export_name}.cmake
    DESTINATION share/unofficial-libmem
)

# Install headers
install(
    DIRECTORY ${LIBMEM_INC}/libmem
    DESTINATION include
)

# Config and version files for the package
include(CMakePackageConfigHelpers)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/unofficial-libmem-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-libmem-config.cmake
    INSTALL_DESTINATION share/unofficial-libmem
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libmem-config-version.cmake"
    VERSION 5.0.2
    COMPATIBILITY SameMajorVersion
)

# Install the config and version files
install(
    FILES
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-libmem-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-libmem-config-version.cmake
    DESTINATION share/unofficial-libmem
)
