include(CMakeFindDependencyMacro)
find_dependency(OpenSSL)
set(slikenet_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../include")
include(${CMAKE_CURRENT_LIST_DIR}/slikenetTargets.cmake)
