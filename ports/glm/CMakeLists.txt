cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(glm LANGUAGES CXX)

include(GNUInstallDirs)

add_library(glm INTERFACE)
target_include_directories(glm INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(TARGETS glm EXPORT glm)

install(
    EXPORT glm
    FILE glm-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/glm"
    NAMESPACE glm::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/glm"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    PATTERN "CMakeLists.txt" EXCLUDE
)
