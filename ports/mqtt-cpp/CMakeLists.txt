cmake_minimum_required(VERSION 3.13)
project(mqtt_cpp_iface CXX)

add_library(mqtt_cpp_iface INTERFACE)

target_include_directories(mqtt_cpp_iface INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

install(TARGETS mqtt_cpp_iface
    EXPORT mqtt_cpp_iface
)
install(EXPORT mqtt_cpp_iface FILE mqtt_cpp_iface-targets.cmake NAMESPACE mqtt_cpp_iface:: DESTINATION share/mqtt_cpp_iface)

