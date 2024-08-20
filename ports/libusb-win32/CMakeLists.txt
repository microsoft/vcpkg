cmake_minimum_required(VERSION 3.0)
project(libusb-win32)

set(lib_headers src/lusb0_usb.h)

set(lib_srcs src/descriptors.c
             src/error.c
             src/install.c
             src/registry.c
             src/usb.c
             src/windows.c
             libusb0.def)

add_library(libusb0 ${lib_srcs})
target_include_directories(libusb0 PRIVATE "src/driver")
target_link_libraries(libusb0 Setupapi)
target_compile_definitions(libusb0 PRIVATE "-D_CRT_SECURE_NO_WARNINGS")

install(
    TARGETS libusb0
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib   
    LIBRARY DESTINATION lib)

install(
    FILES ${lib_headers}
    DESTINATION include)