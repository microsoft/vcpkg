cmake_minimum_required(VERSION 3.24)
project(fastlowess-vcpkg VERSION 4.1.0 LANGUAGES CXX)

include(CMakePackageConfigHelpers)

if(NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "This prebuilt package requires the x64 MSVC ABI.")
endif()
set(import_library "${CMAKE_CURRENT_BINARY_DIR}/fastlowess_cpp.dll.lib")
add_custom_command(
    OUTPUT "${import_library}"
    COMMAND
        "${CMAKE_AR}" /nologo /machine:x64
        "/def:${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def"
        "/out:${import_library}"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def"
    VERBATIM
)
add_custom_target(fastlowess-import-library ALL DEPENDS "${import_library}")

install(FILES "${FASTLOWESS_BINARY}" DESTINATION bin)
install(FILES "${import_library}" DESTINATION lib)
install(
    FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.h"
        "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess.hpp"
    DESTINATION include
)
if(EXISTS "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess_version.h")
    install(
        FILES
            "${FASTLOWESS_SOURCE_DIR}/bindings/cpp/include/fastlowess_version.h"
        DESTINATION include
    )
endif()

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/fastlowessConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfig.cmake"
    INSTALL_DESTINATION share/fastlowess
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/fastlowessConfigVersion.cmake"
    DESTINATION share/fastlowess
)
