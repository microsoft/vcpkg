cmake_minimum_required(VERSION 3.4)
project(metal-cpp)
include(GNUInstallDirs)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(metal STATIC impl.cpp)
target_include_directories(metal INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_link_libraries(metal PUBLIC stdc++ "-framework Metal" "-framework Foundation" "-framework QuartzCore")

install(
    DIRECTORY Foundation QuartzCore Metal
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    TARGETS metal EXPORT unofficial-metal-cpp-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/
)

install(
    EXPORT unofficial-metal-cpp-config
    NAMESPACE unofficial-metal-cpp::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metal-cpp
)
