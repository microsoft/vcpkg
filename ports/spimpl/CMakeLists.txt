cmake_minimum_required(VERSION 3.23 FATAL_ERROR)

PROJECT(spimpl)

add_library (spimpl INTERFACE "spimpl.h")

install(TARGETS spimpl 
    EXPORT spimplTargets)

install(FILES "spimpl.h" DESTINATION include/spimpl)

install(EXPORT spimplTargets
  FILE spimplTargets.cmake
  NAMESPACE spimpl::
  DESTINATION share/spimpl
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "spimplConfigVersion.cmake" 
    VERSION 2025.01.23
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES "spimplConfig.cmake" 
    "${CMAKE_CURRENT_BINARY_DIR}/spimplConfigVersion.cmake"
    DESTINATION share/spimpl
)
