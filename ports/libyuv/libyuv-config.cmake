include(CMakeFindDependencyMacro)
find_dependency(JPEG REQUIRED)

set(libyuv_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../include")
include("${CMAKE_CURRENT_LIST_DIR}/libyuv-targets.cmake")
