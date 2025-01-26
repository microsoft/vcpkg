cmake_minimum_required(VERSION 3.30)
project(libcurl-test C)

block(SCOPE_FOR VARIABLES)
    # blocked by FindOpenSSL in CMake 3.30: set(CMAKE_DISABLE_FIND_PACKAGE_PkgConfig 1)

    find_package(CURL COMPONENTS HTTP2 REQUIRED)

    add_executable(main main.c)
    target_link_libraries(main PRIVATE CURL::libcurl)
endblock()

block(SCOPE_FOR VARIABLES)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(libcurl_pc libcurl REQUIRED IMPORTED_TARGET)

    add_executable(main-pkgconfig main.c)
    target_link_libraries(main-pkgconfig PRIVATE PkgConfig::libcurl_pc)
endblock()