cmake_minimum_required(VERSION 3.25)
project(whereami)
set(PROJECT_VERSION ${PROJECT_VERSION_STRING})

add_library(whereami STATIC src/whereami.c src/whereami.h)
add_library(whereami::whereami ALIAS whereami)
target_include_directories(whereami PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)

set_target_properties(whereami PROPERTIES PUBLIC_HEADER "src/whereami.h")

include(GNUInstallDirs)
install(TARGETS whereami
        EXPORT whereamiTargets
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Create and install package files
include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/unofficial-whereamiConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-whereamiConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-whereami
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-whereamiConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-whereamiConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/unofficial-whereamiConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-whereami
)

# Export Targets and install that to unofficial-whereamiTargets.cmake
install(
    EXPORT whereamiTargets
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-whereami
    NAMESPACE unofficial::whereami::
    FILE unofficial-whereamiTargets.cmake
)
