cmake_minimum_required(VERSION 3.29)

project(vcpkg-ci-aurora-au LANGUAGES CXX)

find_package(Au CONFIG REQUIRED)

add_executable(test_au_client test_au_client.cc)
target_link_libraries(test_au_client PRIVATE Au::au)
target_compile_features(test_au_client PRIVATE cxx_std_14)
