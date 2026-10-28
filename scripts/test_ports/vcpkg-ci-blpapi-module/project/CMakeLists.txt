cmake_minimum_required(VERSION 3.28)

project(blpapi_module_check LANGUAGES CXX)

find_package(blpapi REQUIRED CONFIG)

add_executable(vcpkg_ci_blpapi main.cpp)
target_compile_features(vcpkg_ci_blpapi PRIVATE cxx_std_20)
target_link_libraries(vcpkg_ci_blpapi PRIVATE blpapi)

target_sources(vcpkg_ci_blpapi
    PUBLIC
        FILE_SET CXX_MODULES
        BASE_DIRS "${blpapi_INCLUDE_DIR}"
        FILES "${blpapi_MODULE_INTERFACE}"
)
