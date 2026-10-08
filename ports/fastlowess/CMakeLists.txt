cmake_minimum_required(VERSION 3.24)
project(fastlowess-vcpkg VERSION "${FASTLOWESS_VERSION}" LANGUAGES CXX)

include(CMakePackageConfigHelpers)

if(NOT FASTLOWESS_PACKAGE_DIR OR NOT FASTLOWESS_BINARY_NAME)
    message(
        FATAL_ERROR
        "FASTLOWESS_PACKAGE_DIR and FASTLOWESS_BINARY_NAME are required."
    )
endif()

install(
    FILES
        "${FASTLOWESS_PACKAGE_DIR}/fastlowess.hpp"
        "${FASTLOWESS_PACKAGE_DIR}/fastlowess.h"
        "${FASTLOWESS_PACKAGE_DIR}/fastlowess_version.h"
    DESTINATION include
)
install(
    FILES "${FASTLOWESS_PACKAGE_DIR}/THIRD_PARTY_LICENSES.html"
    DESTINATION share/fastlowess
)

if(WIN32)
    if(NOT MSVC)
        message(FATAL_ERROR "Prebuilt Windows packages require the MSVC ABI.")
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
    set(FASTLOWESS_IMPORT_LIBRARY_NAME fastlowess.lib)
    set(import_library
        "${CMAKE_CURRENT_BINARY_DIR}/${FASTLOWESS_IMPORT_LIBRARY_NAME}"
    )
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
    install(
        FILES "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        DESTINATION bin
    )
    install(
        FILES "${import_library}"
        DESTINATION lib
    )
    set(FASTLOWESS_LIBRARY_DIR bin)
else()
    install(
        FILES "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        DESTINATION lib
    )
    set(FASTLOWESS_LIBRARY_DIR lib)
endif()

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-fastlowessConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastlowessConfig.cmake"
    INSTALL_DESTINATION share/unofficial-fastlowess
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastlowessConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastlowessConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastlowessConfigVersion.cmake"
    DESTINATION share/unofficial-fastlowess
)
