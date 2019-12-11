cmake_minimum_required(VERSION 3.13)
project(clickhouse-cpp CXX)

find_package(lz4 CONFIG REQUIRED)
find_package(cityhash CONFIG REQUIRED)

file(GLOB_RECURSE SOURCES "clickhouse/*.cpp")
file(GLOB_RECURSE HEADERS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "clickhouse/*.h")

add_library(clickhouse-cpp STATIC ${SOURCES})

target_compile_definitions(clickhouse-cpp PRIVATE LZ4_DISABLE_DEPRECATE_WARNINGS)

set_target_properties(clickhouse-cpp PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)

target_include_directories(clickhouse-cpp PUBLIC
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

target_link_libraries(clickhouse-cpp 
    PRIVATE lz4::lz4
    PRIVATE cityhash
)

install(TARGETS clickhouse-cpp EXPORT clickhouse-cpp-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT clickhouse-cpp-config DESTINATION share/cmake/clickhouse-cpp)

foreach (HEADER ${HEADERS} )
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(FILES ${HEADER} DESTINATION include/${HEADER_DIR})
endforeach()
