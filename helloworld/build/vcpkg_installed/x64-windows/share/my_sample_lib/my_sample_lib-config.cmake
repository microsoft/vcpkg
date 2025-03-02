include(CMakeFindDependencyMacro)
find_dependency(fmt CONFIG REQUIRED)
include("${CMAKE_CURRENT_LIST_DIR}/my_sample_lib-targets.cmake")
