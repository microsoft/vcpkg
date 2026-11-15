cmake_minimum_required(VERSION 3.24)
project(fastlowess-vcpkg VERSION "${FASTLOWESS_VERSION}" LANGUAGES CXX)

include(CMakePackageConfigHelpers)

if(NOT FASTLOWESS_PACKAGE_DIR OR NOT FASTLOWESS_BINARY_NAME)
    message(
        FATAL_ERROR
        "FASTLOWESS_PACKAGE_DIR and FASTLOWESS_BINARY_NAME are required."
    )
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles(
        "#include <features.h>\n#ifndef __GLIBC__\n#error Target libc is not glibc\n#endif\nint main() { return 0; }"
        FASTLOWESS_TARGET_USES_GLIBC
    )
    if(NOT FASTLOWESS_TARGET_USES_GLIBC)
        message(
            FATAL_ERROR
            "The curated fastlowess port supports glibc Linux targets only."
        )
    endif()
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

set(FASTLOWESS_IMPORT_LIBRARY_NAME fastlowess.lib)
set(FASTLOWESS_DEBUG_IMPORT_LIBRARY_NAME fastlowess.lib)

if(WIN32)
    if(NOT MSVC)
        message(FATAL_ERROR "Prebuilt Windows packages require the MSVC ABI.")
    endif()
    if(NOT FASTLOWESS_DEBUG_PACKAGE_DIR OR NOT FASTLOWESS_DEBUG_BINARY_NAME)
        message(
            FATAL_ERROR
            "Windows packages require FASTLOWESS_DEBUG_PACKAGE_DIR and FASTLOWESS_DEBUG_BINARY_NAME."
        )
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

    function(fastlowess_generate_import_library output_lib def_stem dll_name)
        set(def_path "${CMAKE_CURRENT_BINARY_DIR}/${def_stem}.def")
        file(READ "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def" import_definition)
        string(
            REPLACE "fastlowess-win32-x64.dll"
            "${dll_name}"
            import_definition
            "${import_definition}"
        )
        file(WRITE "${def_path}" "${import_definition}")
        add_custom_command(
            OUTPUT "${output_lib}"
            COMMAND
                "${CMAKE_AR}" /nologo "/machine:${import_machine}"
                "/def:${def_path}"
                "/out:${output_lib}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fastlowess.def"
            VERBATIM
        )
    endfunction()

    set(release_import_library
        "${CMAKE_CURRENT_BINARY_DIR}/${FASTLOWESS_IMPORT_LIBRARY_NAME}"
    )
    set(debug_import_library
        "${CMAKE_CURRENT_BINARY_DIR}/debug-${FASTLOWESS_DEBUG_IMPORT_LIBRARY_NAME}"
    )
    # Both import libraries must name the final installed DLL
    # (debug/bin uses the same filename as bin after RENAME).
    fastlowess_generate_import_library(
        "${release_import_library}"
        fastlowess-release
        "${FASTLOWESS_BINARY_NAME}"
    )
    fastlowess_generate_import_library(
        "${debug_import_library}"
        fastlowess-debug
        "${FASTLOWESS_BINARY_NAME}"
    )
    add_custom_target(
        fastlowess-import-libraries ALL
        DEPENDS "${release_import_library}" "${debug_import_library}"
    )

    install(
        FILES "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        DESTINATION bin
    )
    install(
        FILES "${FASTLOWESS_DEBUG_PACKAGE_DIR}/${FASTLOWESS_DEBUG_BINARY_NAME}"
        DESTINATION debug/bin
        RENAME "${FASTLOWESS_BINARY_NAME}"
    )
    install(FILES "${release_import_library}" DESTINATION lib)
    install(
        FILES "${debug_import_library}"
        DESTINATION debug/lib
        RENAME "${FASTLOWESS_DEBUG_IMPORT_LIBRARY_NAME}"
    )
    set(FASTLOWESS_LIBRARY_DIR bin)
else()
    install(
        FILES "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        DESTINATION lib
    )
    install(
        FILES "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        DESTINATION debug/lib
    )
    set(FASTLOWESS_LIBRARY_DIR lib)
    set(FASTLOWESS_DEBUG_BINARY_NAME "${FASTLOWESS_BINARY_NAME}")
endif()

set(FASTLOWESS_MACOS_RPATH_PREFIX "@rpath/")
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
