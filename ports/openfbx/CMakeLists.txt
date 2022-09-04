cmake_minimum_required(VERSION 3.11)

project(OpenFBX LANGUAGES CXX)

include(GNUInstallDirs)

find_package(miniz REQUIRED)

add_library(OpenFBX src/ofbx.cpp)
target_link_libraries(OpenFBX PRIVATE miniz::miniz)

target_include_directories(OpenFBX
        PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/>)

target_compile_definitions(OpenFBX PRIVATE _LARGEFILE64_SOURCE)
set_target_properties(OpenFBX PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

install(TARGETS OpenFBX EXPORT openfbxTargets
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        INCLUDES DESTINATION include)

include(CMakePackageConfigHelpers)
configure_package_config_file(
        openfbxConfig.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/openfbxConfig.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/openfbx"
)

install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/openfbxConfig.cmake"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/openfbx"
)

install(
        EXPORT openfbxTargets
        FILE openfbxTargets.cmake
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/openfbx
)

install(FILES ${CMAKE_SOURCE_DIR}/src/ofbx.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
