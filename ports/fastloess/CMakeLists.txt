cmake_minimum_required(VERSION 3.24)
project(fastloess-vcpkg VERSION "${FASTLOESS_VERSION}" LANGUAGES CXX)

include(CMakePackageConfigHelpers)

if(NOT FASTLOESS_PACKAGE_DIR OR NOT FASTLOESS_BINARY_NAME)
    message(
        FATAL_ERROR
        "FASTLOESS_PACKAGE_DIR and FASTLOESS_BINARY_NAME are required."
    )
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles(
        "#include <features.h>\n#ifndef __GLIBC__\n#error Target libc is not glibc\n#endif\nint main() { return 0; }"
        FASTLOESS_TARGET_USES_GLIBC
    )
    if(NOT FASTLOESS_TARGET_USES_GLIBC)
        message(FATAL_ERROR "The curated fastloess port supports glibc Linux targets only.")
    endif()
endif()

install(
    FILES
        "${FASTLOESS_PACKAGE_DIR}/fastloess.hpp"
        "${FASTLOESS_PACKAGE_DIR}/fastloess.h"
        "${FASTLOESS_PACKAGE_DIR}/fastloess_version.h"
    DESTINATION include
)
install(
    FILES "${FASTLOESS_PACKAGE_DIR}/THIRD_PARTY_LICENSES.html"
    DESTINATION share/fastloess
)

if(WIN32)
    if(NOT MSVC)
        message(FATAL_ERROR "Prebuilt Windows packages require the MSVC ABI.")
    endif()
    if(FASTLOESS_ARCH STREQUAL "x64")
        set(import_machine x64)
    elseif(FASTLOESS_ARCH STREQUAL "arm64")
        set(import_machine ARM64)
    else()
        message(
            FATAL_ERROR
            "Unsupported Windows architecture: ${FASTLOESS_ARCH}"
        )
    endif()
    set(FASTLOESS_IMPORT_LIBRARY_NAME fastloess.lib)
    set(import_library
        "${CMAKE_CURRENT_BINARY_DIR}/${FASTLOESS_IMPORT_LIBRARY_NAME}"
    )
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/fastloess.def" import_definition)
    string(
        REPLACE "fastloess-win32-x64.dll"
        "${FASTLOESS_BINARY_NAME}"
        import_definition
        "${import_definition}"
    )
    file(
        WRITE "${CMAKE_CURRENT_BINARY_DIR}/fastloess.def"
        "${import_definition}"
    )
    add_custom_command(
        OUTPUT "${import_library}"
        COMMAND
            "${CMAKE_AR}" /nologo "/machine:${import_machine}"
            "/def:${CMAKE_CURRENT_BINARY_DIR}/fastloess.def"
            "/out:${import_library}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fastloess.def"
        VERBATIM
    )
    add_custom_target(fastloess-import-library ALL DEPENDS "${import_library}")
    install(
        FILES "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        DESTINATION bin
    )
    install(
        FILES "${import_library}"
        DESTINATION lib
    )
    set(FASTLOESS_LIBRARY_DIR bin)
else()
    install(
        FILES "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        DESTINATION lib
    )
    set(FASTLOESS_LIBRARY_DIR lib)
endif()

set(FASTLOESS_MACOS_RPATH_PREFIX "@rpath/")
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/fastloessConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/fastloessConfig.cmake"
    INSTALL_DESTINATION share/fastloess
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/fastloessConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/fastloessConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/fastloessConfigVersion.cmake"
    DESTINATION share/fastloess
)
