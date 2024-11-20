cmake_minimum_required(VERSION 3.30)
project(libavif-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD "11")
endif()

find_package(libavif CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    $<TARGET_NAME:avif>
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libavif_pc libavif REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.cpp)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::libavif_pc
)
