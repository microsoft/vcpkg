cmake_minimum_required(VERSION 3.8)
project(uvw)

find_package(libuv CONFIG REQUIRED)

add_library(uvw INTERFACE)
if (TARGET uv)
    target_link_libraries(uvw INTERFACE uv)
else()
    target_link_libraries(uvw INTERFACE uv_a)
endif()

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
