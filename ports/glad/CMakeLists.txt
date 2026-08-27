cmake_minimum_required(VERSION 3.15)
project(glad C)

set(GLAD_SOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "" FORCE)
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/GladConfig.cmake")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(GLAD_ARGS STATIC REPRODUCIBLE)
if(GLAD_LOADER)
    list(APPEND GLAD_ARGS LOADER)
endif()
list(APPEND GLAD_ARGS API ${GLAD_API})
if(NOT GLAD_ALL_EXTENSIONS)
    list(APPEND GLAD_ARGS EXTENSIONS NONE)
endif()
glad_add_library(glad ${GLAD_ARGS})
set_property(TARGET glad PROPERTY INTERFACE_INCLUDE_DIRECTORIES
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include>;$<INSTALL_INTERFACE:include>"
)

# glad 1 provided this "official" CMake config name and target.
include(CMakePackageConfigHelpers)
install(TARGETS glad EXPORT glad-targets ARCHIVE DESTINATION lib INCLUDES DESTINATION include)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include/" DESTINATION include)
install(EXPORT glad-targets FILE glad-targets.cmake NAMESPACE glad:: DESTINATION share/glad)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/glad-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/glad-config.cmake"
    INSTALL_DESTINATION share/glad
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/glad-config.cmake" DESTINATION share/glad)
