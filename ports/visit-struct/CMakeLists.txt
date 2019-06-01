cmake_minimum_required(VERSION 3.11)
project(visit_struct)

add_library(visit_struct INTERFACE)

install(TARGETS visit_struct
    EXPORT visit_struct-targets
    INCLUDES DESTINATION include)

install(EXPORT visit_struct-targets
    FILE visit_struct-config.cmake
    NAMESPACE visit_struct::
    DESTINATION share/visit_struct)

install(DIRECTORY
    include/visit_struct
    DESTINATION include)
