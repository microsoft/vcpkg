cmake_minimum_required(VERSION 3.5)
project(libsocketcan)

set(sources
    src/libsocketcan.c
)

include_directories(include)

add_library(${PROJECT_NAME} ${sources})


install(TARGETS ${PROJECT_NAME}
    EXPORT libsocketcan-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/
    DESTINATION include
    CONFIGURATIONS Release
    FILES_MATCHING PATTERN "*.h"
)

install(EXPORT libsocketcan-targets
    FILE libsocketcan-targets.cmake
    NAMESPACE libsocketcan::
    DESTINATION share/libsocketcan
)


include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/libsocketcan-config-version.cmake"
        VERSION "0.0.12"
        COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/libsocketcan-config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/libsocketcan-config.cmake"
        INSTALL_DESTINATION share/libsocketcan
)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/libsocketcan-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/libsocketcan-config-version.cmake"
        DESTINATION share/libsocketcan
)
