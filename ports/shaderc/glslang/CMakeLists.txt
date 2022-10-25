cmake_minimum_required(VERSION 3.11)

find_package(glslang CONFIG REQUIRED)

set_property(TARGET glslang::glslang PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET glslang::OSDependent PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET glslang::OGLCompiler PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET glslang::HLSL PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET glslang::SPIRV PROPERTY IMPORTED_GLOBAL TRUE)
set_property(TARGET glslang::MachineIndependent PROPERTY IMPORTED_GLOBAL TRUE)

add_library(glslang ALIAS glslang::glslang)
add_library(OSDependent ALIAS glslang::OSDependent)
add_library(OGLCompiler ALIAS glslang::OGLCompiler)
add_library(HLSL ALIAS glslang::HLSL)
add_library(SPIRV ALIAS glslang::SPIRV)
add_library(MachineIndependent ALIAS glslang::MachineIndependent)

find_package(Threads REQUIRED)

find_path(glslang_SOURCE_DIR glslang/Public/ShaderLang.h)
set(glslang_SOURCE_DIR "${glslang_SOURCE_DIR}/glslang" "${glslang_SOURCE_DIR}" CACHE STRING "" FORCE)
