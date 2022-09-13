cmake_minimum_required(VERSION 3.11)

project(OpenFBX LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)

include(GNUInstallDirs)

find_package(miniz REQUIRED)

add_library(unofficial-openfbx src/ofbx.cpp)
target_link_libraries(unofficial-openfbx PRIVATE miniz::miniz)

target_include_directories(unofficial-openfbx
        PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/>)

target_compile_definitions(unofficial-openfbx PRIVATE _LARGEFILE64_SOURCE)
set_target_properties(unofficial-openfbx PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

install(TARGETS unofficial-openfbx EXPORT openfbxTargets
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include
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

install(FILES ${CMAKE_SOURCE_DIR}/src/ofbx.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    EXPORT openfbxTargets
    NAMESPACE unoffical::
    DESTINATION ${CMAKE_INSTALL_DATADIR}/openfbx
)
