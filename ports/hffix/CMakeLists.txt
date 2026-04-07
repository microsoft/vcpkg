cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME hffix)
project(${PROJECT_NAME})

include(GNUInstallDirs)

add_library(hffix INTERFACE)
target_include_directories(hffix INTERFACE
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(
    FILES
        ${CMAKE_SOURCE_DIR}/include/hffix.hpp
        ${CMAKE_SOURCE_DIR}/include/hffix_fields.hpp
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    TARGETS hffix
    EXPORT hffix-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(EXPORT hffix-config DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME} NAMESPACE ${PROJECT_NAME}::)