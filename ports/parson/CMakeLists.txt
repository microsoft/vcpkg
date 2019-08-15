cmake_minimum_required(VERSION 3.5)
project(parson C)

add_library(parson parson.c)
target_include_directories(parson PUBLIC $<INSTALL_INTERFACE:include>)

install(TARGETS parson
    EXPORT unofficial-parson-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-parson-targets
    FILE unofficial-parson-config.cmake
    NAMESPACE unofficial::parson::
    DESTINATION share/unofficial-parson
)
