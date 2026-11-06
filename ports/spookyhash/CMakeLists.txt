cmake_minimum_required(VERSION 3.14)

project(spookyhash VERSION "${SPOOKYHASH_VERSION}" LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(spookyhash cplus/SpookyV2.cpp)
add_library(spookyhash::spookyhash ALIAS spookyhash)
target_include_directories(spookyhash PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cplus>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

install(TARGETS spookyhash EXPORT spookyhash-targets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)
install(FILES cplus/SpookyV2.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(EXPORT spookyhash-targets
    NAMESPACE spookyhash::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/spookyhash"
)

configure_package_config_file(
    spookyhash-config.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/spookyhash-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/spookyhash"
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/spookyhash-config-version.cmake"
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/spookyhash-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/spookyhash-config-version.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/spookyhash"
)
