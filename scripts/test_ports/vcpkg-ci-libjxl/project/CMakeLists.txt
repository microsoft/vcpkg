cmake_minimum_required(VERSION 3.30)
project(libjxl-test C)

find_package(PkgConfig REQUIRED)

pkg_check_modules(libjxl libjxl IMPORTED_TARGET REQUIRED)
add_executable(main_jxl main.c)
target_link_libraries(main_jxl PRIVATE PkgConfig::libjxl)

pkg_check_modules(libjxl_threads libjxl_threads IMPORTED_TARGET REQUIRED)
add_executable(main_jxl_threads threads.c)
target_link_libraries(main_jxl_threads PRIVATE PkgConfig::libjxl_threads)

pkg_check_modules(libjxl_cms libjxl_cms IMPORTED_TARGET REQUIRED)
add_executable(main_jxl_cms cms.c)
target_link_libraries(main_jxl_cms PRIVATE PkgConfig::libjxl_cms)
