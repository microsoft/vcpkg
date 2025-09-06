cmake_minimum_required(VERSION 3.16)
project(whisper-cpp-test)

find_package(whisper CONFIG REQUIRED)

add_executable(test-cmake main.cxx)
add_library(imported::whisper ALIAS whisper)
target_link_libraries(test-cmake PRIVATE imported::whisper)

find_package(PkgConfig REQUIRED)
pkg_check_modules(whisper-cpp whisper REQUIRED IMPORTED_TARGET)

add_executable(test-pkconfig main.cxx)
target_link_libraries(test-pkconfig PRIVATE PkgConfig::whisper-cpp)

# Vulkan on Android isn't really useful, but the build can succeed.
if(ANDROID AND TARGET ggml::ggml-vulkan)
    # Instantiates VULKAN_HPP_DEFAULT_DISPATCH_LOADER_DYNAMIC_STORAGE
    find_package(Vulkan REQUIRED)
    target_link_libraries(test-cmake PRIVATE Vulkan::Vulkan)
    target_compile_definitions(test-cmake PRIVATE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1)
    target_link_libraries(test-pkconfig PRIVATE Vulkan::Vulkan)
    target_compile_definitions(test-pkconfig PRIVATE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1)
endif()
