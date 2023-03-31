cmake_minimum_required(VERSION 3.18)

project(tinyfsm)

add_library(tinyfsm INTERFACE)
target_include_directories(tinyfsm INTERFACE $<INSTALL_INTERFACE:include>)
set_target_properties(tinyfsm PROPERTIES PUBLIC_HEADER include/tinyfsm.hpp)

install(TARGETS tinyfsm EXPORT unofficial-tinyfsm-config PUBLIC_HEADER DESTINATION include)
install(EXPORT unofficial-tinyfsm-config NAMESPACE unofficial::tinyfsm:: DESTINATION share/unofficial-tinyfsm)
