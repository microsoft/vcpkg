cmake_minimum_required(VERSION 3.20)
project(vcpkg_ci_jsonifier LANGUAGES CXX)

find_package(Jsonifier CONFIG REQUIRED)

add_executable(vcpkg_ci_jsonifier_cmake_target main.cpp)
target_compile_features(vcpkg_ci_jsonifier_cmake_target PRIVATE cxx_std_20)
target_link_libraries(vcpkg_ci_jsonifier_cmake_target PRIVATE Jsonifier::Jsonifier)

find_path(JSONIFIER_INCLUDE_DIR NAMES jsonifier REQUIRED)

add_executable(vcpkg_ci_jsonifier_direct_header main.cpp)
target_compile_features(vcpkg_ci_jsonifier_direct_header PRIVATE cxx_std_20)
target_include_directories(vcpkg_ci_jsonifier_direct_header PRIVATE "${JSONIFIER_INCLUDE_DIR}")
