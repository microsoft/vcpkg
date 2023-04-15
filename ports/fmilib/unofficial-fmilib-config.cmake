include(CMakeFindDependencyMacro)
find_dependency(expat CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-fmilib-targets.cmake")
