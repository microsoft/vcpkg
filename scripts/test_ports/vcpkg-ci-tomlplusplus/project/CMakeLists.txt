cmake_minimum_required(VERSION 3.30)
project(tomlplusplus-test CXX)


find_package(tomlplusplus CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE tomlplusplus::tomlplusplus)


find_package(PkgConfig REQUIRED)
pkg_check_modules(tomlplusplus_pc tomlplusplus REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.cpp)
target_compile_features(main-pkconfig PRIVATE cxx_std_17)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::tomlplusplus_pc)
