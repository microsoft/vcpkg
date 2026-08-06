cmake_minimum_required(VERSION 3.15)
project(libnsgif VERSION 1.0.0 LANGUAGES C)

add_library(nsgif src/gif.c src/lzw.c)

target_compile_definitions(nsgif PRIVATE NSGIF_NAME=nsgif NSGIF_VERSION=1.0.0)
target_include_directories(nsgif PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:include>")

install(TARGETS nsgif
    EXPORT nsgif_targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
install(FILES include/nsgif.h DESTINATION include)

include(CMakePackageConfigHelpers)
set(PACKAGE_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libnsgif-config.cmake")
set(INSTALL_CONFIG_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-libnsgif")

configure_package_config_file(unofficial-libnsgif-config.cmake.in
    "${PACKAGE_CONFIG_FILE}"
    INSTALL_DESTINATION "${INSTALL_CONFIG_DIR}"
)

install(EXPORT nsgif_targets
    NAMESPACE unofficial::libnsgif::
    FILE unofficial-libnsgif-targets.cmake
    DESTINATION "${INSTALL_CONFIG_DIR}"
)

install(FILES "${PACKAGE_CONFIG_FILE}" DESTINATION "${INSTALL_CONFIG_DIR}")
