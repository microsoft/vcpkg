cmake_minimum_required(VERSION 3.30)
project(libmodbus-test C)

find_package(libmodbus CONFIG REQUIRED)
add_library(imported::modbus ALIAS modbus)

add_executable(main main.c)
target_link_libraries(main PRIVATE imported::modbus)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libmodbus_pc libmodbus REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::libmodbus_pc
)
