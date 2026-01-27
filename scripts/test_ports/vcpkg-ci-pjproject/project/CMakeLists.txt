cmake_minimum_required(VERSION 3.30)
project(vcpkg-ci-pjproject C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libpjproject_pc REQUIRED IMPORTED_TARGET libpjproject)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::libpjproject_pc
)
