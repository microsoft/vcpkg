cmake_minimum_required(VERSION 3.15)
project(gifdec LANGUAGES C)

add_library(gifdec gifdec.c)
target_include_directories(gifdec PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:include>")

install(TARGETS gifdec
    EXPORT gifdec_targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(FILES gifdec.h DESTINATION include)

include(CMakePackageConfigHelpers)
set(PACKAGE_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-gifdec-config.cmake")
set(INSTALL_CONFIG_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-gifdec")

configure_package_config_file(unofficial-gifdec-config.cmake.in
    "${PACKAGE_CONFIG_FILE}"
    INSTALL_DESTINATION "${INSTALL_CONFIG_DIR}"
)

install(EXPORT gifdec_targets
    NAMESPACE unofficial::gifdec::
    FILE unofficial-gifdec-targets.cmake
    DESTINATION "${INSTALL_CONFIG_DIR}"
)

install(FILES "${PACKAGE_CONFIG_FILE}" DESTINATION "${INSTALL_CONFIG_DIR}")
