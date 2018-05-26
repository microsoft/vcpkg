cmake_minimum_required(VERSION 3.8)
project(cctz CXX)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    option(INSTALL_HEADERS "Install header files" ON)
else()
    option(INSTALL_HEADERS "Install header files" OFF)
endif()

file(GLOB SOURCES src/*.cc)
list(FILTER SOURCES EXCLUDE REGEX "_test.cc$|benchmarks|_tool.cc$")

file(GLOB HEADERS include/cctz/*.h)

add_library(cctz ${SOURCES})
target_include_directories(cctz PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

if(INSTALL_HEADERS)
    install(FILES ${HEADERS} DESTINATION "include/cctz")
endif()

install(TARGETS cctz EXPORT unofficial-cctz-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-cctz-targets
    FILE unofficial-cctz-config.cmake
    NAMESPACE unofficial::
    DESTINATION share/unofficial-cctz
)
