include(vcpkg_common_functions)


set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/directx-shader-compiler.src")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXShaderCompiler
    REF 0a32799e58261bbef658a7d62a60fc05a12eabeb
    SHA512 9b96489d0a60f2015d14f9dbb85977b52142937e0836cb1a24d5df8b685a631d5347737b38cb6841d402eb6e8669429dcd37116897519e00378b563e1818e217
    HEAD_REF master
)


vcpkg_from_github(
    OUT_SOURCE_PATH SPIRV-Headers_SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF 29c11140baaf9f7fdaa39a583672c556bf1795a1
    SHA512 9b6b7671ca9a5eaa121650b615d392841950bf0a199f474b52451a20666025fe9acc10bf3e5095f715432ed18bb070788f6c70a4a6fa5a58d6c2d464225a644b
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/external/SPIRV-Headers")
file(RENAME "${SPIRV-Headers_SOURCE_PATH}" "${SOURCE_PATH}/external/SPIRV-Headers")

vcpkg_from_github(
    OUT_SOURCE_PATH SPIRV-Tools_SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF bbd80462f5c89e9a225edabaca1215032c62e459
    SHA512 fbe4665ba58c9bbf9fc23cb7856bb2beaf034a15d26a3ef0d45687a2964622d2422c683519144989fadaa036d9b04fa8059040a73f68df0a5dc07fec0cf16715
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/external/SPIRV-Tools")
file(RENAME "${SPIRV-Tools_SOURCE_PATH}" "${SOURCE_PATH}/external/SPIRV-Tools")



vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS

        # These should be equal to the options specified in `<dxc-src-dir>/utils/cmake-predefined-config-params`
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON 
        -DLLVM_APPEND_VC_REV:BOOL=ON 
        -DLLVM_DEFAULT_TARGET_TRIPLE:STRING=dxil-ms-dx
        -DLLVM_ENABLE_EH:BOOL=ON
        -DLLVM_ENABLE_RTTI:BOOL=ON
        -DLLVM_INCLUDE_DOCS:BOOL=OFF
        -DLLVM_INCLUDE_EXAMPLES:BOOL=OFF
        -DLLVM_INCLUDE_TESTS:BOOL=OFF
        -DLLVM_OPTIMIZED_TABLEGEN:BOOL=OFF
        -DLLVM_REQUIRES_EH:BOOL=ON
        -DLLVM_REQUIRES_RTTI:BOOL=ON
        -DLLVM_TARGETS_TO_BUILD:STRING=None
        -DLIBCLANG_BUILD_STATIC:BOOL=ON
        -DCLANG_BUILD_EXAMPLES:BOOL=OFF
        -DCLANG_CL:BOOL=OFF
        -DCLANG_ENABLE_ARCMT:BOOL=OFF
        -DCLANG_ENABLE_STATIC_ANALYZER:BOOL=OFF
        -DCLANG_INCLUDE_TESTS:BOOL=OFF
        -DHLSL_INCLUDE_TESTS:BOOL=ON
        -DENABLE_SPIRV_CODEGEN:BOOL=ON

        -DSPIRV_BUILD_TESTS=OFF
)

vcpkg_install_cmake()


file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/dxc" "${CURRENT_PACKAGES_DIR}/tools/dxc")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/dxc-3.7" "${CURRENT_PACKAGES_DIR}/tools/dxc-3.7")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


configure_file(
    "${SOURCE_PATH}/LICENSE.TXT" 
    "${CURRENT_PACKAGES_DIR}/share/directx-shader-compiler/copyright" 
    COPYONLY
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/usage" 
    "${CURRENT_PACKAGES_DIR}/share/directx-shader-compiler/usage" 
    COPYONLY
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" 
    "${CURRENT_PACKAGES_DIR}/share/directx-shader-compiler/directx-shader-compiler-config.cmake" 
    @ONLY
)

