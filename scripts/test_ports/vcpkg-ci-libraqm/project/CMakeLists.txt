cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-libraqm LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(raqm REQUIRED IMPORTED_TARGET raqm)

add_executable(main main.c)
target_link_libraries(main PRIVATE PkgConfig::raqm)
install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-libraqm)
