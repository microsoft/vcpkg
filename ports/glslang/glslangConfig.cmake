include(CMakeFindDependencyMacro)
find_dependency(SPIRV-Tools)
find_dependency(SPIRV-Tools-opt)
# libraries
include("${CMAKE_CURRENT_LIST_DIR}/OSDependentTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/OGLCompilerTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/HLSLTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/glslangTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SPIRVTargets.cmake")
# tools
include("${CMAKE_CURRENT_LIST_DIR}/glslangValidatorTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/spirv-remapTargets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SPVRemapperTargets.cmake")
