cmake_minimum_required(VERSION 3.13)

project(VTFLIB VERSION 1.3.2)

include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

add_library(VTFLIB "")

generate_export_header(VTFLIB
        EXPORT_MACRO_NAME VTFLIB_API
        )

file(GLOB SOURCES VTFLib/*.cpp)
file(GLOB HEADERS VTFLib/*.h ${CMAKE_CURRENT_BINARY_DIR}/*.h)

target_sources(VTFLIB
        PRIVATE
            ${SOURCES}
        )

target_include_directories(VTFLIB
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/VTFLib>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:include/vtflib>
        )

set_target_properties(VTFLIB
    PROPERTIES
        PUBLIC_HEADER "${HEADERS}"
)

export(TARGETS VTFLIB
        NAMESPACE VTFLIB::
        FILE VTFLIB/VTFLIBTargets.cmake
        )

configure_package_config_file(VTFLIBConfig.cmake.in
        ${PROJECT_BINARY_DIR}/vtflib-config.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/VTFLIB
        )

write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/VTFLIB/VTFLIBConfigVersion.cmake
        COMPATIBILITY SameMinorVersion
)

install(FILES
    ${PROJECT_BINARY_DIR}/vtflib-config.cmake
    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/cmake/VTFLIB
)

install(TARGETS VTFLIB
        EXPORT VTFLIBTargets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vtflib
        )

install(EXPORT VTFLIBTargets
        NAMESPACE VTFLIB::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/VTFLIB
        )
