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

message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
list(FIND CMAKE_PREFIX_PATH "SYSTEM_LIBS" system_libs)
list(FIND CMAKE_PREFIX_PATH "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" vcpkg)
if(system_libs LESS 0)
    message(SEND_ERROR "VCPKG_PREFER_SYSTEM_LIBS check: failed (Cannot find SYSTEM_LIBS in CMAKE_PREFIX_PATH.)")
elseif(vcpkg LESS 0)
    message(SEND_ERROR "VCPKG_PREFER_SYSTEM_LIBS check: failed (Cannot find vcpkg path in CMAKE_PREFIX_PATH.")
elseif(VCPKG_PREFER_SYSTEM_LIBS AND system_libs GREATER vcpkg)
    message(SEND_ERROR "VCPKG_PREFER_SYSTEM_LIBS check: failed (actual: ${VCPKG_PREFER_SYSTEM_LIBS}, but vcpkg paths are before system paths in CMAKE_PREFIX_PATH.)")
elseif(NOT VCPKG_PREFER_SYSTEM_LIBS AND system_libs LESS vcpkg)
    message(SEND_ERROR "VCPKG_PREFER_SYSTEM_LIBS check: failed (actual: ${VCPKG_PREFER_SYSTEM_LIBS}, but vcpkg paths are after system paths in CMAKE_PREFIX_PATH.)")
else()
    message(STATUS "VCPKG_PREFER_SYSTEM_LIBS check: success (actual: ${VCPKG_PREFER_SYSTEM_LIBS})")
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
foreach(package ${FIND_PACKAGES})
    string(TOUPPER "${package}" package_upper)
    set(CMAKE_FIND_DEBUG_MODE ON)
    find_package("${package}" QUIET)
    set(CMAKE_FIND_DEBUG_MODE OFF)
    if(NOT ${package}_FOUND AND NOT ${package_upper}_FOUND)
        message(SEND_ERROR "find_package(${package}) check: failed")
    elseif(DEFINED ${package_upper}_LIBRARIES)
        message(STATUS "${package_upper}_LIBRARIES: ${${package_upper}_LIBRARIES}")
        message(STATUS "find_package(${package}) check: success")
        target_link_libraries(exe PRIVATE ${${package_upper}_LIBRARIES})
    elseif(DEFINED ${package}_LIBRARIES)
        message(STATUS "${package}_LIBRARIES: ${${package}_LIBRARIES}")
        message(STATUS "find_package(${package}) check: success")
        target_link_libraries(exe PRIVATE ${${package}_LIBRARIES})
    else()
        message(STATUS "${package}_LIBRARIES: undefined")
        message(STATUS "find_package(${package}) check: success")
    endif()
endforeach()
