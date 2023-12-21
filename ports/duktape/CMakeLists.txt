cmake_minimum_required(VERSION 3.15)

set(duktape_MAJOR_VERSION 2)
set(duktape_MINOR_VERSION 7)
set(duktape_PATCH_VERSION 0)
set(duktape_VERSION ${duktape_MAJOR_VERSION}.${duktape_MINOR_VERSION}.${duktape_PATCH_VERSION})

project(duktape VERSION ${duktape_VERSION})

include(GNUInstallDirs)

file(GLOB_RECURSE DUKTAPE_SOURCES "${CMAKE_CURRENT_LIST_DIR}/src/*.c")
file(GLOB_RECURSE DUKTAPE_HEADERS "${CMAKE_CURRENT_LIST_DIR}/src/*.h")

add_library(duktape ${DUKTAPE_SOURCES} ${DUKTAPE_HEADERS})
target_include_directories(duktape PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")
set_target_properties(duktape PROPERTIES VERSION ${duktape_VERSION})
set_target_properties(duktape PROPERTIES SOVERSION ${duktape_MAJOR_VERSION})

install(TARGETS duktape EXPORT duktape)

install(
    EXPORT duktape
    NAMESPACE duktape::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/duktape"
    FILE duktape-targets.cmake
)

install(
    FILES ${DUKTAPE_HEADERS}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/duktape-config-version.cmake"
    COMPATIBILITY SameMajorVersion
)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/duktape-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/duktape-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/duktape"
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/cmake/duktape-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake/duktape-config-version.cmake"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/duktape"
)

set(prefix "")
set(LIBDIR "/lib")
set(VERSION "${duktape_VERSION}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/duktape.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/duktape.pc"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/duktape.pc"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
)
