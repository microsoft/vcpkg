cmake_minimum_required(VERSION 3.10)
project(msh3-test C)

block()
    set(CMAKE_DISABLE_FIND_PACKAGE_PkgConfig 1)

    find_package(msh3 CONFIG REQUIRED)
    if(NOT TARGET msh3)
        message(SEND_ERROR "No target 'msh3'")
    endif()

    add_executable(msh3_cmake main.c)
    target_link_libraries(msh3_cmake msh3)
endblock()

block()
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(libmsh3 IMPORTED_TARGET REQUIRED libmsh3)

    add_executable(msh3_pkgconfig main.c)
    target_link_libraries(msh3_pkgconfig PkgConfig::libmsh3)
endblock()
