cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(glm LANGUAGES CXX)

include(GNUInstallDirs)

add_library(glm INTERFACE)
target_include_directories(glm INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(
    TARGETS glm EXPORT glm-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/
)

install(
    EXPORT glm-config
    NAMESPACE glm::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/glm
)

install(
    DIRECTORY ${CMAKE_SOURCE_DIR}/glm
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.hpp*" PATTERN "*.inl*" PATTERN "*.h*"
)
