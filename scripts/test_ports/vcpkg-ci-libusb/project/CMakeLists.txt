cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-libusb C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libusb IMPORTED_TARGET REQUIRED libusb-1.0)

add_executable(main main.c)
target_link_libraries(main PRIVATE PkgConfig::libusb)
