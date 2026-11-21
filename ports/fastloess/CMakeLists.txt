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
        message(
            FATAL_ERROR
            "The curated fastloess port supports glibc Linux targets only."
        )
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

set(FASTLOESS_IMPORT_LIBRARY_NAME fastloess.lib)
set(FASTLOESS_DEBUG_IMPORT_LIBRARY_NAME fastloess.lib)

if(WIN32)
    if(NOT MSVC)
        message(FATAL_ERROR "Prebuilt Windows packages require the MSVC ABI.")
    endif()
    if(NOT FASTLOESS_DEBUG_PACKAGE_DIR OR NOT FASTLOESS_DEBUG_BINARY_NAME)
        message(
            FATAL_ERROR
            "Windows packages require FASTLOESS_DEBUG_PACKAGE_DIR and FASTLOESS_DEBUG_BINARY_NAME."
        )
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

    function(fastloess_generate_import_library output_lib def_stem dll_name)
        set(def_path "${CMAKE_CURRENT_BINARY_DIR}/${def_stem}.def")
        file(READ "${CMAKE_CURRENT_SOURCE_DIR}/fastloess.def" import_definition)
        string(
            REPLACE "fastloess-win32-x64.dll"
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
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/fastloess.def"
            VERBATIM
        )
    endfunction()

    set(release_import_library
        "${CMAKE_CURRENT_BINARY_DIR}/${FASTLOESS_IMPORT_LIBRARY_NAME}"
    )
    set(debug_import_library
        "${CMAKE_CURRENT_BINARY_DIR}/debug-${FASTLOESS_DEBUG_IMPORT_LIBRARY_NAME}"
    )
    # Both import libraries must name the final installed DLL
    # (debug/bin uses the same filename as bin after RENAME).
    fastloess_generate_import_library(
        "${release_import_library}"
        fastloess-release
        "${FASTLOESS_BINARY_NAME}"
    )
    fastloess_generate_import_library(
        "${debug_import_library}"
        fastloess-debug
        "${FASTLOESS_BINARY_NAME}"
    )
    add_custom_target(
        fastloess-import-libraries ALL
        DEPENDS "${release_import_library}" "${debug_import_library}"
    )

    install(
        FILES "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        DESTINATION bin
    )
    install(
        FILES "${FASTLOESS_DEBUG_PACKAGE_DIR}/${FASTLOESS_DEBUG_BINARY_NAME}"
        DESTINATION debug/bin
        RENAME "${FASTLOESS_BINARY_NAME}"
    )
    install(FILES "${release_import_library}" DESTINATION lib)
    install(
        FILES "${debug_import_library}"
        DESTINATION debug/lib
        RENAME "${FASTLOESS_DEBUG_IMPORT_LIBRARY_NAME}"
    )
    set(FASTLOESS_LIBRARY_DIR bin)
    set(FASTLOESS_HAS_SEPARATE_DEBUG TRUE)
else()
    install(
        FILES "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        DESTINATION lib
    )
    install(
        FILES "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        DESTINATION debug/lib
    )
    set(FASTLOESS_LIBRARY_DIR lib)
    set(FASTLOESS_HAS_SEPARATE_DEBUG TRUE)
    set(FASTLOESS_DEBUG_BINARY_NAME "${FASTLOESS_BINARY_NAME}")
endif()

set(FASTLOESS_MACOS_RPATH_PREFIX "@rpath/")
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-fastloessConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastloessConfig.cmake"
    INSTALL_DESTINATION share/unofficial-fastloess
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastloessConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastloessConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-fastloessConfigVersion.cmake"
    DESTINATION share/unofficial-fastloess
)
