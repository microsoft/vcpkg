cmake_minimum_required(VERSION 3.4)
project(cmake-user LANGUAGES C)

message(STATUS "CMAKE_COMMAND: ${CMAKE_COMMAND}")
set(CHECK_CMAKE_VERSION "NOTFOUND" CACHE STRING "Version of CMake expected to be found")
if(NOT CHECK_CMAKE_VERSION)
    message(WARNING "CMake version check: skipped (actual: ${CMAKE_VERSION})")
elseif(NOT CHECK_CMAKE_VERSION VERSION_EQUAL CMAKE_VERSION)
    message(SEND_ERROR "CMake version check: failed (actual: ${CMAKE_VERSION} expected: ${CHECK_CMAKE_VERSION})")
else()
    message(STATUS "CMake version check: success (actual: ${CMAKE_VERSION})")
endif()

# add_library overload
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lib.c"  "int lib_unused() { return 1; }")
add_library(lib "${CMAKE_CURRENT_BINARY_DIR}/lib.c")

# add_executable overload
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/exe.c"  "int main() { return 0; }")
add_executable(exe "${CMAKE_CURRENT_BINARY_DIR}/exe.c")

# install overload
set(X_VCPKG_APPLOCAL_DEPS_INSTALL 1)
install(TARGETS exe lib
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
)

# find_package overload and wrapper
set(FIND_PACKAGES "" CACHE STRING "List of packages to be found and used")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
foreach(package ${FIND_PACKAGES})
    string(TOUPPER "${package}" package_upper)
    set(CMAKE_FIND_DEBUG_MODE ON)
    find_package("${package}" QUIET)
    set(CMAKE_FIND_DEBUG_MODE OFF)
    if(NOT ${package}_FOUND AND NOT ${package_upper}_FOUND)
        message(SEND_ERROR "find_package(${package}) check: failed")
        continue()
    endif()
    # REQUIRED changes the behaviour find_package_handle_standard_args.
    find_package("${package}" REQUIRED)
    message(STATUS "find_package(${package}) check: success")

    set(libraries_var "")
    if(DEFINED ${package}_LIBRARIES)
        set(libraries_var "${package}_LIBRARIES")
    elseif(DEFINED ${package_upper}_LIBRARIES)
        set(libraries_var "${package_upper}_LIBRARIES")
    elseif(DEFINED ${package}_LIBRARY)
        set(libraries_var "${package}_LIBRARY")
    elseif(DEFINED ${package_upper}_LIBRARY)
        set(libraries_var "${package_upper}_LIBRARY")
    else()
        message(STATUS "${package}_LIBRARY/IES: undefined")
        continue()
    endif()
    set(libraries "${${libraries_var}}")
    message(STATUS "${libraries_var}: ${libraries}")

    if(package STREQUAL "Intl" AND NOT Intl_LIBRARY)
        continue() # using libintl.h from C runtime library
    endif()
    target_link_libraries(exe PRIVATE ${libraries})

    set(last_keyword "")
    foreach(item IN LISTS libraries)
        if(item STREQUAL "optimized" OR item STREQUAL "debug")
            set(last_keyword "${item}")
            continue()
        endif()
        string(FIND "${item}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/" starts_with_release)
        string(FIND "${item}" "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/" starts_with_debug)
        if(starts_with_release EQUAL "0")
            if(last_keyword STREQUAL "optimized")
                # okay
            elseif(last_keyword STREQUAL "debug")
                message(SEND_ERROR "Release lib for 'debug' keyword: ${item}")
            elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
                message(SEND_ERROR "Release lib for 'Debug' build: ${item}")
            endif()
        elseif(starts_with_debug EQUAL "0")
            if(last_keyword STREQUAL "debug")
                # okay
            elseif(last_keyword STREQUAL "optimized")
                message(SEND_ERROR "Debug lib for 'optimized' keyword: ${item}")
            elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
                message(SEND_ERROR "Debug lib for 'Release' build: ${item}")
            endif()
        endif()
        set(last_keyword "")
        continue()
    endforeach()
endforeach()
