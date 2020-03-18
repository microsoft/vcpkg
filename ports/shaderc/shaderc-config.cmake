include(CMakeFindDependencyMacro)
find_dependency(SPIRV-Tools)
find_dependency(SPIRV-Tools-opt)
find_dependency(glslang)

include("${CMAKE_CURRENT_LIST_DIR}/OSDependentTargets.cmake")
