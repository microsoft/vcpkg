include(CMakeFindDependencyMacro)
find_dependency(Protobuf CONFIG)
 
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-cld3-targets.cmake")
