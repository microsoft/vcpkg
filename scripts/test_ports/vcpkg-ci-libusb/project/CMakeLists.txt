cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-libusb C)

find_package(libusb CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE libusb::usb-1.0)
