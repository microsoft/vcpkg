cmake_minimum_required(VERSION 3.13)

project(VTFLIB VERSION 1.3.2)

include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

add_library(VTFLIB "")

generate_export_header(VTFLIB
        EXPORT_MACRO_NAME VTFLIB_API
        )

target_sources(VTFLIB
    PRIVATE
        VTFLib/Error.cpp
        VTFLib/FileReader.cpp
        VTFLib/FileWriter.cpp
        VTFLib/Float16.cpp
        VTFLib/MemoryReader.cpp
        VTFLib/MemoryWriter.cpp
        VTFLib/Proc.cpp
        VTFLib/ProcReader.cpp
        VTFLib/ProcWriter.cpp
        VTFLib/VMTFile.cpp
        VTFLib/VMTGroupNode.cpp
        VTFLib/VMTIntegerNode.cpp
        VTFLib/VMTNode.cpp
        VTFLib/VMTSingleNode.cpp
        VTFLib/VMTStringNode.cpp
        VTFLib/VMTValueNode.cpp
        VTFLib/VMTWrapper.cpp
        VTFLib/VTFFile.cpp
        VTFLib/VTFLib.cpp
        VTFLib/VTFMathlib.cpp
        VTFLib/VTFWrapper.cpp
)

target_include_directories(VTFLIB
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/VTFLib>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

set_target_properties(VTFLIB
        PROPERTIES
        PUBLIC_HEADER "lib/VTFLib.h"
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
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )

install(EXPORT VTFLIBTargets
        NAMESPACE VTFLIB::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/VTFLIB
        )
