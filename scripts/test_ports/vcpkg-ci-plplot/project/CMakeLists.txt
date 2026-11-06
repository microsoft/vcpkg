cmake_minimum_required(VERSION 3.30)
project(plplot-test C CXX)

find_package(plplot CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE
    PLPLOT::plplot
)
target_compile_definitions(main PRIVATE USING_CMAKE)

find_package(PkgConfig REQUIRED)
pkg_check_modules(plplot_pc plplot REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE
    PkgConfig::plplot_pc
)
