cmake_minimum_required(VERSION 3.20)
project(libaio C)
include(GNUInstallDirs)
file(GLOB SRC_FILES src/*.c)
add_library(aio ${SRC_FILES})
target_include_directories(aio PUBLIC "${PROJECT_SOURCE_DIR}/src")
install(TARGETS aio)
install(FILES src/libaio.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
set(PKG_CONFIG_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/pkgconfig.pc.in" "${PKG_CONFIG_FILE_NAME}" @ONLY)
install(FILES "${PKG_CONFIG_FILE_NAME}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
