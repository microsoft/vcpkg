# Included right after project(): installed dependencies replace the git submodules (absent in vcpkg sources).
find_package(macro_utils_c CONFIG REQUIRED)
find_package(unofficial-c-logging CONFIG REQUIRED)
# Upstream CMake links the c-logging targets by their unprefixed names.
if(NOT TARGET c_logging_v2)
    add_library(c_logging_v2 ALIAS unofficial::c-logging::c_logging_v2)
endif()
