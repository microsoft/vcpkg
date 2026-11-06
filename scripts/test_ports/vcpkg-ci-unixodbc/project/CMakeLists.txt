cmake_minimum_required(VERSION 3.30)
project(unixodbc-test C)

# legacy vcpkg-only name, now forwarding to "unofficial" names
find_package(unixodbc CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE UNIX::odbc)

find_package(PkgConfig REQUIRED)
pkg_check_modules(unixodbc_pc odbc REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::unixodbc_pc)
