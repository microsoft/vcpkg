include(vcpkg_common_functions)


set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/directx-shader-compiler.src")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXShaderCompiler
    REF 7279b1857d34f182ee219a489c11033601ebfe51
    SHA512 33c438f2f05893f0603508bb23031a5522916b786eefd475498e9e110ddae56836c3f5e2db8e4f8d151f79b5f3e3c2ea5f202b6065690f2473a87fd13968d441
    HEAD_REF master
    PATCHES "handle-imported-spirv-tools.patch"
)


vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS

        -DSPIRV_BUILD_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF

        -DSPIRV-Headers_SOURCE_DIR="${CURRENT_INSTALLED_DIR}"
        -Dspirv-tools_SOURCE_DIR="${CURRENT_INSTALLED_DIR}"

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
