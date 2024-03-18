set(SHADERC_GLSLANG_DIR "" CACHE STRING "unused")
find_package(glslang CONFIG REQUIRED)
add_library(glslang ALIAS glslang::glslang)
add_library(MachineIndependent ALIAS glslang::MachineIndependent)
add_library(OSDependent ALIAS glslang::OSDependent)
add_library(SPIRV ALIAS glslang::SPIRV)

find_path(glslang_SOURCE_DIR glslang/Public/ShaderLang.h REQUIRED)
set(glslang_SOURCE_DIR "${glslang_SOURCE_DIR}/glslang" "${glslang_SOURCE_DIR}" CACHE STRING "" FORCE)

set(SHADERC_SPIRV_TOOLS_DIR "" CACHE STRING "unused")
find_package(SPIRV-Tools CONFIG REQUIRED)
add_library(SPIRV-Tools ALIAS SPIRV-Tools-static) # as linked by SPIRV-Tools-opt
find_package(SPIRV-Tools-opt CONFIG REQUIRED)
