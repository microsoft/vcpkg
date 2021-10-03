include(CMakeFindDependencyMacro)

find_dependency(Threads)

foreach(targets OGLCompiler OSDependent glslang glslang-default-resource-limits glslangValidator HLSL SPIRV spirv-remap SPVRemapper)
    include("${CMAKE_CURRENT_LIST_DIR}/${targets}Targets.cmake" OPTIONAL)
endforeach()
