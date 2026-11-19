cmake_minimum_required(VERSION 3.16)
project(libraw-test C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# CMake config
find_package(libraw CONFIG REQUIRED)

add_executable(main-c main.c)
target_link_libraries(main-c PRIVATE libraw::raw)

add_executable(main-cpp main.cpp)
target_link_libraries(main-cpp PRIVATE libraw::raw_r)

# pkg-config
find_package(PkgConfig REQUIRED)
pkg_check_modules(libraw REQUIRED IMPORTED_TARGET libraw)
pkg_check_modules(libraw_r REQUIRED IMPORTED_TARGET libraw_r)

add_executable(main-c-pkgconfig main.c)
target_link_libraries(main-c-pkgconfig PRIVATE PkgConfig::libraw)
# libraw.pc does not carry the C++ runtime requirement
set_target_properties(main-c-pkgconfig PROPERTIES LINKER_LANGUAGE CXX)

add_executable(main-cpp-pkgconfig main.cpp)
target_link_libraries(main-cpp-pkgconfig PRIVATE PkgConfig::libraw_r)

install(TARGETS main-c main-cpp main-c-pkgconfig main-cpp-pkgconfig RUNTIME DESTINATION "bin/vcpkg-ci-libraw")
