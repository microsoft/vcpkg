cmake_minimum_required(VERSION 3.20)
project(libaio
    VERSION 0.3.113
    DESCRIPTION "The Linux-native asynchronous I/O facility"
)
file(GLOB SRC_FILES src/*.c)
add_library(aio ${SRC_FILES})
target_include_directories(aio PUBLIC "${PROJECT_SOURCE_DIR}/src")
install(TARGETS aio LIBRARY DESTINATION lib)
install(FILES src/libaio.h DESTINATION include)
set(PKG_CONFIG_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/pkgconfig.pc.in" "${PKG_CONFIG_FILE_NAME}" @ONLY)
install(FILES "${PKG_CONFIG_FILE_NAME}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
