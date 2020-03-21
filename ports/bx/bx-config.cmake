include(CMakeFindDependencyMacro)
find_dependency(Threads)
include("${CMAKE_CURRENT_LIST_DIR}/bx-targets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/tool-targets.cmake")