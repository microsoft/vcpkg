cmake_minimum_required(VERSION 3.11)
project(visit_struct)

add_library(visit_struct INTERFACE)

install(TARGETS visit_struct
    EXPORT unofficial-visit_struct-targets
    INCLUDES DESTINATION include)

install(EXPORT unofficial-visit_struct-targets
    FILE unofficial-visit_struct-config.cmake
    NAMESPACE unofficial::visit_struct::
    DESTINATION share/unofficial-visit_struct)

install(DIRECTORY
    include/visit_struct
    DESTINATION include)
