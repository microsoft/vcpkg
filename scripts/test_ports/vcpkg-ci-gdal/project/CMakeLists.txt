cmake_minimum_required(VERSION 3.30)
project(gdal-test C CXX)

set(CMAKE_CXX_STANDARD 11)

block(SCOPE_FOR VARIABLES)
    find_package(GDAL CONFIG REQUIRED)

    add_executable(main-cmake main.cpp)
    target_link_libraries(main-cmake PRIVATE GDAL::GDAL)
endblock()

block(SCOPE_FOR VARIABLES)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(PC_GDAL gdal REQUIRED IMPORTED_TARGET)

    add_executable(main-pkgconfig main.cpp)
    if(WIN32 AND NOT MINGW)
        target_link_libraries(main-pkgconfig PRIVATE PkgConfig::PC_GDAL)
    else()
        # Use raw flags, avoid find_library
        target_compile_options(main-pkgconfig PRIVATE ${PC_GDAL_CFLAGS})
        target_link_libraries(main-pkgconfig PRIVATE ${PC_GDAL_LDFLAGS})
    endif()
endblock()
