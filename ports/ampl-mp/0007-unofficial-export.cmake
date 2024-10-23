
install(
    EXPORT unofficial-mp-targets
    NAMESPACE
    DESTINATION share/unofficial-mp
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-mp-config.cmake.in" [[
@PACKAGE_INIT@
include(CMakeFindDependencyMacro)
find_dependency(ampl-asl CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-mp-targets.cmake")
]]
)

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-mp-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-mp-config.cmake"
    INSTALL_DESTINATION "share/unofficial-mp"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-mp-config.cmake"
    DESTINATION "share/unofficial-mp"
)
