cmake_minimum_required(VERSION 3.10)
project(dcmtk-test CXX)

set(CMAKE_CXX_STANDARD 17)

find_package(DCMTK CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE DCMTK::DCMTK)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DCMTK dcmtk REQUIRED IMPORTED_TARGET)

add_executable(main-pkgconfig main.cpp)
target_link_libraries(main-pkgconfig PRIVATE PkgConfig::DCMTK)
target_compile_options(main-pkgconfig PRIVATE "\$<\$<CXX_COMPILER_ID:MSVC>:/Zc:__cplusplus>")
