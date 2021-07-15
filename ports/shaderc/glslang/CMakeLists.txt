cmake_minimum_required(VERSION 3.11)

find_package(glslang CONFIG REQUIRED)

set_property(TARGET glslang PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET OSDependent PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET OGLCompiler PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET HLSL PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET SPIRV PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET MachineIndependent PROPERTY IMPORTED_GLOBAL TRUE)

find_path(glslang_SOURCE_DIR glslang/Public/ShaderLang.h)
set(glslang_SOURCE_DIR "${glslang_SOURCE_DIR}/glslang" "${glslang_SOURCE_DIR}" CACHE STRING "" FORCE)
