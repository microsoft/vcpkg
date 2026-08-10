cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-bcg729 LANGUAGES C)

find_package(BCG729 CONFIG REQUIRED)
add_executable(main main.c)
target_link_libraries(main PRIVATE bcg729)

find_package(PkgConfig REQUIRED)
pkg_check_modules(bcg729 IMPORTED_TARGET REQUIRED libbcg729)
add_executable(main_pkg main.c)
target_link_libraries(main_pkg PRIVATE PkgConfig::bcg729)
