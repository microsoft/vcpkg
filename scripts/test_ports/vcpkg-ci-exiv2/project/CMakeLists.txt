cmake_minimum_required(VERSION 3.10)
project(exiv2-test CXX)

set(CMAKE_CXX_STANDARD 11)

block()
    find_package(exiv2 CONFIG REQUIRED)

    add_executable(main "${SOURCE_PATH}/samples/exifdata.cpp")
    target_link_libraries(main PRIVATE Exiv2::exiv2lib)
endblock()

block()
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(exiv2 exiv2 REQUIRED IMPORTED_TARGET)

    add_executable(main-pkgconfig "${SOURCE_PATH}/samples/exifdata.cpp")
    target_link_libraries(main-pkgconfig PRIVATE PkgConfig::exiv2)
endblock()
