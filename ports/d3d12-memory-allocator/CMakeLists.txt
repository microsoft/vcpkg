cmake_minimum_required(VERSION 3.0)
project(d3d12-memory-allocator)

add_library(${PROJECT_NAME} STATIC 
    "src/D3D12MemAlloc.h"
    "src/D3D12MemAlloc.cpp"
)

set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "src/D3D12MemAlloc.h")
#target_include_directories(${PROJECT_NAME} PRIVATE "src/")

install(
    TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-config
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION include/
)
install(
    EXPORT ${PROJECT_NAME}-config DESTINATION cmake/
    NAMESPACE "unofficial::"
)