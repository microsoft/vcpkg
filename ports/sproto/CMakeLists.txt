cmake_minimum_required(VERSION 3.14)
project(sproto C)

set(CMAKE_C_STANDARD 99)

find_package(unofficial-lua CONFIG REQUIRED)

add_library(sproto sproto.c lsproto.c)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(sproto PRIVATE SPROTO_BUILD_DLL)
    # Set symbol visibility for GCC/Clang
    if(NOT WIN32)
        target_compile_options(sproto PRIVATE -fvisibility=hidden)
    endif()
else()
    target_compile_definitions(sproto PUBLIC SPROTO_STATIC)
endif()

target_link_libraries(sproto PRIVATE lua)

target_include_directories(sproto PRIVATE ${LUA_INCLUDE_DIR})

target_include_directories(sproto PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

install(TARGETS sproto 
    EXPORT sproto-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES sproto.h 
    DESTINATION include
)

install(EXPORT sproto-targets
    FILE sproto-targets.cmake
    NAMESPACE unofficial::sproto::
    DESTINATION share/unofficial-sproto
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/sproto-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sproto-config.cmake"
    INSTALL_DESTINATION share/unofficial-sproto
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sproto-config.cmake"
    DESTINATION share/unofficial-sproto
)
