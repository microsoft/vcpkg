cmake_minimum_required(VERSION 3.4)
project(tinyfiledialogs C)

add_library(tinyfiledialogs tinyfiledialogs.c)

target_include_directories(tinyfiledialogs INTERFACE $<INSTALL_INTERFACE:include/tinyfiledialogs>)

install(
    TARGETS tinyfiledialogs
    EXPORT tinyfiledialogsConfig
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
install(
    FILES tinyfiledialogs.h
    DESTINATION "${CMAKE_INSTALL_PREFIX}/include/tinyfiledialogs"
)

export(
    TARGETS tinyfiledialogs
    NAMESPACE tinyfiledialogs::
    FILE "${CMAKE_CURRENT_BINARY_DIR}/tinyfiledialogsConfig.cmake"
)
install(
    EXPORT tinyfiledialogsConfig
    NAMESPACE tinyfiledialogs::
    DESTINATION share/tinyfiledialogs
)
