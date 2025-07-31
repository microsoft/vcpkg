cmake_minimum_required(VERSION 3.14)
project(sproto C)

set(CMAKE_C_STANDARD 99)

# Add the main library - let vcpkg control static/shared
add_library(sproto sproto.c)

# For Windows DLL, export all symbols
if(WIN32 AND BUILD_SHARED_LIBS)
    set_target_properties(sproto PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

# Ensure consistent CRT linkage on Windows
if(WIN32 AND MSVC)
    if(BUILD_SHARED_LIBS)
        # For shared library, use dynamic CRT
        set_target_properties(sproto PROPERTIES 
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
        )
    else()
        # For static library, match vcpkg's CRT setting
        if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
            set_target_properties(sproto PROPERTIES 
                MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
            )
        else()
            set_target_properties(sproto PROPERTIES 
                MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
            )
        endif()
    endif()
endif()
target_include_directories(sproto PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Install library and headers
install(TARGETS sproto 
    EXPORT sproto-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES sproto.h 
    DESTINATION include
)

# Install CMake config files
install(EXPORT sproto-targets
    FILE sproto-targets.cmake
    NAMESPACE unofficial-sproto::
    DESTINATION share/sproto
)

# Create and install config file
include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/sproto-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/sproto-config.cmake"
    INSTALL_DESTINATION share/sproto
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/sproto-config.cmake"
    DESTINATION share/sproto
)