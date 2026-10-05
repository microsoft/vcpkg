cmake_minimum_required(VERSION 3.24)
project(fastlowess-vcpkg VERSION 4.1.0 LANGUAGES CXX)

include(CMakePackageConfigHelpers)
get_filename_component(FASTLOWESS_BINARY_NAME "${FASTLOWESS_BINARY}" NAME)

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "This prebuilt package requires a 64-bit target ABI.")
endif()

if(WIN32)
    if(NOT MSVC)
        message(FATAL_ERROR "Prebuilt Windows packages require the MSVC ABI.")
    endif()
    if(FASTLOWESS_ARCH STREQUAL "")
        set(FASTLOWESS_ARCH x64)
    endif()
    if(FASTLOWESS_ARCH STREQUAL "x64")
        set(import_machine x64)
    elseif(FASTLOWESS_ARCH STREQUAL "arm64")
        set(import_machine ARM64)
    else()
        message(
            FATAL_ERROR
            "Unsupported Windows architecture: ${FASTLOWESS_ARCH}"
        )
    endif()

    set(import_library "${CMAKE_CURRENT_BINARY_DIR}/fastlowess_cpp.dll.lib")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def" import_definition)
    string(
        REPLACE "fastlowess-win32-x64.dll"
        "${FASTLOWESS_BINARY_NAME}"
        import_definition
        "${import_definition}"
    )
    file(
        WRITE "${CMAKE_CURRENT_BINARY_DIR}/fastlowess.def"
        "${import_definition}"
    )
    add_custom_command(
        OUTPUT "${import_library}"
        COMMAND
            "${CMAKE_AR}" /nologo "/machine:${import_machine}"
            "/def:${CMAKE_CURRENT_BINARY_DIR}/fastlowess.def"
            "/out:${import_library}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def"
        VERBATIM
    )
    add_custom_target(fastlowess-import-library ALL DEPENDS "${import_library}")

    install(FILES "${FASTLOWESS_BINARY}" DESTINATION bin)
    install(FILES "${import_library}" DESTINATION lib)
else()
    install(FILES "${FASTLOWESS_BINARY}" DESTINATION lib)
endif()
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
