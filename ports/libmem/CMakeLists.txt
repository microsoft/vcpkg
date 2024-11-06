cmake_minimum_required(VERSION 3.22.1)

project(libmem LANGUAGES C CXX ASM)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(targets_export_name unofficial-libmem-target)

if (MSVC AND NOT(BUILD_SHARED_LIBS))
    add_definitions(/DLM_EXPORT)
elseif(NOT(MSVC) AND BUILD_SHARED_LIBS)
    add_definitions(-DLM_EXPORT)
endif()

set(LIBMEM_ARCH ${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "Force a specific architecture")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(keystone REQUIRED)
find_package(capstone CONFIG REQUIRED)

foreach(dep keystone capstone)
    if(NOT ${dep}_FOUND)
        message(FATAL_ERROR "${dep} not found! Please install ${dep}.")
    endif()
endforeach()

set(LIBMEM_DIR "${PROJECT_SOURCE_DIR}")
set(LIBMEM_INC "${LIBMEM_DIR}/include")
set(INTERNAL_DIR "${LIBMEM_DIR}/internal")
set(COMMON_DIR "${LIBMEM_DIR}/src/common")

set(LLVM_DEM_DIR "${LIBMEM_DIR}/external/llvm")
file(GLOB_RECURSE LLVM_DEM_SRC "${LLVM_DEM_DIR}/lib/*.cpp")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    file(GLOB_RECURSE LIBMEM_SRC
        "${LIBMEM_DIR}/src/win/*.c"
        "${LIBMEM_DIR}/src/common/*.c"
        "${LIBMEM_DIR}/src/common/*.cpp"
        "${INTERNAL_DIR}/winutils/*.c"
        "${INTERNAL_DIR}/demangler/*.cpp"
    )
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD")
    set(ARCH_DIR "")
    if("${LIBMEM_ARCH}" MATCHES "x86_64|amd64")
        set(ARCH_DIR "x64")
    elseif("${LIBMEM_ARCH}" MATCHES "i686|i386")
        set(ARCH_DIR "x86")
    endif()

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        file(GLOB LIBMEM_SRC
            "${LIBMEM_DIR}/src/linux/*.c"
            "${LIBMEM_DIR}/src/linux/ptrace/${ARCH_DIR}/*.c"
            "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp"
            "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c"
            "${INTERNAL_DIR}/demangler/*.cpp"
        )
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD")
        file(GLOB LIBMEM_SRC
            "${LIBMEM_DIR}/src/freebsd/*.c"
            "${LIBMEM_DIR}/src/freebsd/ptrace/${ARCH_DIR}/*.c"
            "${LIBMEM_DIR}/src/common/*.c" "${LIBMEM_DIR}/src/common/*.cpp"
            "${INTERNAL_DIR}/posixutils/*.c" "${INTERNAL_DIR}/elfutils/*.c"
            "${INTERNAL_DIR}/demangler/*.cpp"
        )
    endif()
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

file(GLOB_RECURSE LIBMEM_PUBLIC_HEADERS "${LIBMEM_INC}/libmem/*.h" "${LIBMEM_INC}/libmem/*.hpp")

add_library(libmem ${LIBMEM_SRC} ${LLVM_DEM_SRC})

set_target_properties(libmem PROPERTIES 
    PUBLIC_HEADER "${LIBMEM_PUBLIC_HEADERS}"
    POSITION_INDEPENDENT_CODE True)
target_compile_features(libmem PUBLIC cxx_std_17)
target_compile_definitions(libmem PUBLIC LM_EXPORT)

target_include_directories(libmem
    PRIVATE "${LLVM_DEM_DIR}/include" "${LIBMEM_DIR}/src" "${INTERNAL_DIR}" "${COMMON_DIR}" "${LIBMEM_INC}"
    INTERFACE $<INSTALL_INTERFACE:include>
)

if(${CMAKE_SYSTEM_NAME} STREQUAL Windows OR ${CMAKE_SYSTEM_NAME} STREQUAL CYGWIN)
    set(LIBMEM_DEPS
        ${LIBMEM_DEPS}
        user32
        psapi
        ntdll
        shell32
        ole32
    )
    target_compile_definitions(libmem PUBLIC alloca=_alloca)
    if (${CMAKE_SYSTEM_NAME} STREQUAL CYGWIN)
        set(LIBMEM_DEPS
            ${LIBMEM_DEPS}
            uuid
        )
    endif()
elseif(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    set(LIBMEM_DEPS 
        ${LIBMEM_DEPS}
        dl
        stdc++
        m
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL FreeBSD)
    set(LIBMEM_DEPS
        ${LIBMEM_DEPS}
        dl
        kvm
        procstat
        elf
        stdc++
        m
    )
else()
    message(FATAL_ERROR "[!] Unsupported platform")
endif()

target_link_libraries(libmem
    PRIVATE ${LIBMEM_DEPS} ${KEYSTONE_LIBRARIES} capstone::capstone
)

# Install the libmem library and public headers
install(TARGETS libmem
    EXPORT ${targets_export_name}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include/libmem
)

# Install the export file, which allows users to find the target
install(
    EXPORT ${targets_export_name} 
    NAMESPACE unofficial::libmem:: 
    FILE ${targets_export_name}.cmake
    DESTINATION share/unofficial-libmem
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
