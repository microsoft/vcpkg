cmake_minimum_required(VERSION 3.16)
project(Nuklear LANGUAGES C CXX)

option(INSTALL_EXAMPLE "Install the example code" OFF)
option(INSTALL_DEMO "Install the demo code" OFF)

add_library(nuklear INTERFACE)

target_include_directories(nuklear INTERFACE $<INSTALL_INTERFACE:include/nuklear>)
target_compile_definitions(nuklear INTERFACE NK_IMPLEMENTATION)

# Installation
install(
    TARGETS nuklear
    EXPORT unofficial-nuklear
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/nuklear.h" DESTINATION "include/nuklear")


install(EXPORT unofficial-nuklear FILE unofficial-nuklear-config.cmake DESTINATION share/unofficial-nuklear)

if (INSTALL_EXAMPLE)
    install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/example" DESTINATION share/nuklear)

endif()

if (INSTALL_DEMO)
    install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/demo" DESTINATION share/nuklear)

endif()
