include(CMakeFindDependencyMacro)
find_dependency(EXPAT)
if(UNIX)
find_dependency(Boost REQUIRED COMPONENTS uuid)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/dngsdkTargets.cmake")
