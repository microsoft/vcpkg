cmake_minimum_required(VERSION 3.11)

project(OpenFBX LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)

include(GNUInstallDirs)

find_package(miniz REQUIRED)

add_library(openfbx src/ofbx.cpp)
target_link_libraries(openfbx PRIVATE miniz::miniz)

target_include_directories(openfbx
        PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/>)

target_compile_definitions(openfbx PRIVATE _LARGEFILE64_SOURCE)

install(TARGETS openfbx EXPORT unofficial-openfbxTargets
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include
        INCLUDES DESTINATION include)

include(CMakePackageConfigHelpers)
configure_package_config_file(
        unofficial-openfbxConfig.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfbxConfig.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-openfbx"
)

install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfbxConfig.cmake"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-openfbx"
)

install(FILES ${CMAKE_SOURCE_DIR}/src/ofbx.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    EXPORT unofficial-openfbxTargets
    NAMESPACE unoffical::openfbx::
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unofficial-openfbx
)
