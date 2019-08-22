cmake_minimum_required(VERSION 3.8)
project(uvw)

find_package(unofficial-libuv CONFIG REQUIRED)

add_library(uvw INTERFACE)
target_link_libraries(uvw INTERFACE unofficial::libuv::libuv)

install(TARGETS uvw
    EXPORT uvw
    INCLUDES DESTINATION include/)

install(EXPORT uvw
    DESTINATION "share/uvw"
    FILE uvw-targets.cmake
    NAMESPACE uvw::)

install(DIRECTORY
    src/uvw/
    DESTINATION include/uvw/)

install(FILES
    src/uvw.hpp
    DESTINATION include/
)
