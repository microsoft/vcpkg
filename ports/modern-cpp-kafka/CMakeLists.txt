cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(modern-cpp-kafka LANGUAGES CXX)

include(GNUInstallDirs)

find_package(RdKafka CONFIG REQUIRED)

add_library(modern-cpp-kafka INTERFACE)
target_include_directories(modern-cpp-kafka INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/modern-cpp-kafka>)
target_link_libraries(modern-cpp-kafka INTERFACE RdKafka::rdkafka)

install(TARGETS modern-cpp-kafka EXPORT unofficial-modern-cpp-kafka)

install(
    EXPORT unofficial-modern-cpp-kafka
    FILE unofficial-modern-cpp-kafka-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-modern-cpp-kafka"
    NAMESPACE unofficial::modern-cpp-kafka::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/include/kafka"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/modern-cpp-kafka"
)
