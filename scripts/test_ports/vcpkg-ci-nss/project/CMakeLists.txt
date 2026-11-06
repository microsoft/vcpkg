cmake_minimum_required(VERSION 3.30)
project(nss-test C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(nss_pc nss REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::nss_pc
)
