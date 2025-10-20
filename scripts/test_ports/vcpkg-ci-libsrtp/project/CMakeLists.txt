cmake_minimum_required(VERSION 3.30)
project(libsrtp-test C)

find_package(libSRTP CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE libSRTP::srtp2)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libsrtp_pc libsrtp2 REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::libsrtp_pc)
