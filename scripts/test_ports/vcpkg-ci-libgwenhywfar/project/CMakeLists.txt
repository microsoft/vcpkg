cmake_minimum_required(VERSION 3.10)
project(libgwenhywfar-test C)

find_package(PkgConfig REQUIRED)

block()
    pkg_check_modules(gwenhywfar IMPORTED_TARGET REQUIRED gwenhywfar)

    add_executable(libgwenhywfar_pkgconfig main.c)
    target_link_libraries(libgwenhywfar_pkgconfig PkgConfig::gwenhywfar)
endblock()
