cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(stb LANGUAGES C)

include(GNUInstallDirs)

add_library(stb INTERFACE)
target_include_directories(stb INTERFACE $<INSTALL_INTERFACE:"${CMAKE_INSTALL_INCLUDEDIR}/stb">)

install(TARGETS stb EXPORT stb)
file(GLOB HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
install(FILES ${HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/stb")
install(EXPORT stb FILE stb-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/stb" NAMESPACE stb::)
