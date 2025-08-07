cmake_minimum_required(VERSION 3.30)
project(gz-common-test)

find_package(gz-common6 QUIET REQUIRED COMPONENTS av)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE gz-common6::gz-common6-av)

find_package(PkgConfig REQUIRED)
pkg_check_modules(gz-common_pc gz-common6-av REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.cpp)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::gz-common_pc)
if(MSVC)
    target_compile_features(main-pkconfig PRIVATE cxx_std_17)
endif()
