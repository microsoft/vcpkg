cmake_minimum_required(VERSION 3.10)
project(bullet3-test CXX)

set(CMAKE_CXX_STANDARD 11)

block()
    find_package(Bullet CONFIG REQUIRED)

    add_executable(main "${SOURCE_PATH}/examples/HelloWorld/HelloWorld.cpp")
    target_link_libraries(main PRIVATE ${BULLET_LIBRARIES})
endblock()

if(WIN32)
    set(unused "${PKG_CONFIG_EXECUTABLE}")
    return()
endif()

block()
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(bullet bullet REQUIRED IMPORTED_TARGET)

    add_executable(main-pkgconfig "${SOURCE_PATH}/examples/HelloWorld/HelloWorld.cpp")
    target_link_libraries(main-pkgconfig PRIVATE PkgConfig::bullet)
endblock()
