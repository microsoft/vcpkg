cmake_minimum_required(VERSION 3.10)

project(vcpkg-ci-gmime C)

set(CMAKE_C_STANDARD 11)

find_package(PkgConfig REQUIRED)
pkg_check_modules(gmime REQUIRED IMPORTED_TARGET gmime-3.0)

add_executable(main main.c)
target_link_libraries(main PRIVATE PkgConfig::gmime)

if("crypto" IN_LIST FEATURES)
    target_compile_definitions(main PRIVATE ENABLE_CRYPTO)
endif()
