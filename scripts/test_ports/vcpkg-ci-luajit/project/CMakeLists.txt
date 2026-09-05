cmake_minimum_required(VERSION 3.16)
project(luajit-test C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LUAJIT luajit IMPORTED_TARGET REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE PkgConfig::LUAJIT)
install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-luajit)
