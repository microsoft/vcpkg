cmake_minimum_required(VERSION 3.16)
project(llama-cpp-test)

find_package(llama CONFIG REQUIRED)

add_executable(test-cmake main.cxx)
add_library(imported::llama ALIAS llama)
target_link_libraries(test-cmake PRIVATE imported::llama)

find_package(PkgConfig REQUIRED)
pkg_check_modules(llama-cpp llama REQUIRED IMPORTED_TARGET)

add_executable(test-pkconfig main.cxx)
target_link_libraries(test-pkconfig PRIVATE PkgConfig::llama-cpp)

# Vulkan on Android isn't really useful, but the build can succeed.
if(ANDROID AND TARGET ggml::ggml-vulkan)
    # Instantiates VULKAN_HPP_DEFAULT_DISPATCH_LOADER_DYNAMIC_STORAGE
    find_package(Vulkan REQUIRED)
    target_link_libraries(test-cmake PRIVATE Vulkan::Vulkan)
    target_compile_definitions(test-cmake PRIVATE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1)
    target_link_libraries(test-pkconfig PRIVATE Vulkan::Vulkan)
    target_compile_definitions(test-pkconfig PRIVATE VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1)
endif()
