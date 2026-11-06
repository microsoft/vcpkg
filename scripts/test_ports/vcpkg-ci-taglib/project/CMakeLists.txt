cmake_minimum_required(VERSION 3.16)
project(taglib-test LANGUAGES C CXX)

# Verify CMake targets
find_package(taglib CONFIG REQUIRED)

add_executable(main_cmake_cpp main.cpp)
target_link_libraries(main_cmake_cpp PRIVATE TagLib::tag)

add_executable(main_cmake_c main.c)
target_link_libraries(main_cmake_c PRIVATE TagLib::tag_c)

# Verify PkgConfig targets
find_package(PkgConfig REQUIRED)
pkg_check_modules(TagLib REQUIRED IMPORTED_TARGET taglib)
pkg_check_modules(TagLibC REQUIRED IMPORTED_TARGET taglib_c)

add_executable(main_pkg_cpp main.cpp)
target_link_libraries(main_pkg_cpp PRIVATE PkgConfig::TagLib)

add_executable(main_pkg_c main.c)
target_link_libraries(main_pkg_c PRIVATE PkgConfig::TagLibC)
set_target_properties(main_pkg_c PROPERTIES LINKER_LANGUAGE CXX)
