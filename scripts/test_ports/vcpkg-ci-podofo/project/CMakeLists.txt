cmake_minimum_required(VERSION 3.16)
project(podofo-test)

set(CMAKE_CXX_STANDARD 17)

find_package(podofo CONFIG REQUIRED)

add_executable(main main.cxx)
target_link_libraries(main PRIVATE podofo::podofo)

find_package(PkgConfig REQUIRED)
pkg_check_modules(podofo_pc libpodofo REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.cxx)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::podofo_pc)
