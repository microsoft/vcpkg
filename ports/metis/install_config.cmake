install(EXPORT metisTargets
        FILE metisTargets.cmake
        DESTINATION share/metis
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/metisConfig.cmake"
        "include(CMakeFindDependencyMacro)
find_dependency(GKlib CONFIG)
include(\"\${CMAKE_CURRENT_LIST_DIR}/metisTargets.cmake\")
")

# Copied from https://github.com/ceres-solver/ceres-solver/blob/2.2.0/cmake/FindMETIS.cmake#L69-L77
file(READ "${PROJECT_SOURCE_DIR}/include/metis.h" _METIS_VERSION_CONTENTS)
string(REGEX REPLACE ".*#define METIS_VER_MAJOR[ \t]+([0-9]+).*" "\\1"
        METIS_VERSION_MAJOR "${_METIS_VERSION_CONTENTS}")
string(REGEX REPLACE ".*#define METIS_VER_MINOR[ \t]+([0-9]+).*" "\\1"
        METIS_VERSION_MINOR "${_METIS_VERSION_CONTENTS}")
string(REGEX REPLACE ".*#define METIS_VER_SUBMINOR[ \t]+([0-9]+).*" "\\1"
        METIS_VERSION_PATCH "${_METIS_VERSION_CONTENTS}")
set(METIS_VERSION "${METIS_VERSION_MAJOR}.${METIS_VERSION_MINOR}.${METIS_VERSION_PATCH}")

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/metisConfigVersion.cmake"
        VERSION ${METIS_VERSION}
        COMPATIBILITY SameMajorVersion
)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/metisConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/metisConfigVersion.cmake"
        DESTINATION "share/metis"
)
