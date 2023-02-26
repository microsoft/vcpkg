include(CMakeFindDependencyMacro)
find_dependency(expat CONFIG)
find_dependency(minizip CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-fmilib-targets.cmake")
