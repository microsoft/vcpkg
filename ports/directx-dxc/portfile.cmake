set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

# Stay up to date with directx-dxc-tblgen
# dawn requires specific version of directx-dxc, when update this port, please check dawn's requirements
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/DirectXShaderCompiler
    REF e39cf36f5b2a171000a3a1134dadc9f454ff54cf
    SHA512 143f560ec7d8753ea1795fe7b2922823a6f1dcaf2becbd1a88b1a3fd9ce2da006072d8d1c318b834ea4b6344d3ec71d8d8f5b8870e06282fbb5352d16d7ca1cb
    HEAD_REF main
    PATCHES
        001-fix-linkage.patch
        # Update this patch file when update version
        002-fix-gen-version-inc.patch
        003-fix-python.patch
        004-fix-cross-compilation.patch
)

function(z_vcpkg_from_github_to_path)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF" "PATCHES")
    if(EXISTS "${arg_OUT_SOURCE_PATH}")
        file(GLOB children LIST_DIRECTORIES true "${arg_OUT_SOURCE_PATH}/*")
        if(NOT "${children}" STREQUAL "")
            message(FATAL_ERROR "The path ${arg_OUT_SOURCE_PATH} already exists and is not empty.")
        else()
            file(REMOVE_RECURSE "${arg_OUT_SOURCE_PATH}")
        endif()
        unset(children)
    endif()
    vcpkg_from_github(
        OUT_SOURCE_PATH out_source_path
        REPO "${arg_REPO}"
        REF "${arg_REF}"
        SHA512 "${arg_SHA512}"
        HEAD_REF "${arg_HEAD_REF}"
        PATCHES ${arg_PATCHES}
    )
    file(RENAME "${out_source_path}" "${arg_OUT_SOURCE_PATH}")
    file(REMOVE_RECURSE "${out_source_path}")
endfunction()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    z_vcpkg_from_github_to_path(
        OUT_SOURCE_PATH "${SOURCE_PATH}/external/DirectX-Headers"
        REPO microsoft/DirectX-Headers
        REF 980971e835876dc0cde415e8f9bc646e64667bf7
        SHA512 a570068d3c25c68eba34a2653108e2019f888a7392a803f97da9a401713b14bf4235520f0adc37c2f6ffb27cfb118ca7bb0fc8e446b342a7393c9c64afd84ed8
        HEAD_REF main
    )
    z_vcpkg_from_github_to_path(
        OUT_SOURCE_PATH "${SOURCE_PATH}/external/SPIRV-Headers"
        REPO KhronosGroup/SPIRV-Headers
        REF ad9184e76a66b1001c29db9b0a3e87f646c64de0
        SHA512 7d422d2a37617bd05e050000caab431dd35aae86d0925becbe22ea22cbf4be96ecbc429f5442d3b9386026496a91f44e8d1a6867725ee60f4ea3a23d4e2ad969
        HEAD_REF main
    )
    z_vcpkg_from_github_to_path(
        OUT_SOURCE_PATH "${SOURCE_PATH}/external/SPIRV-Tools"
        REPO KhronosGroup/SPIRV-Tools
        REF 0539c81f69a3daeb706fd3477dca61435b475156
        SHA512 d620f1875c8a12201ca90af7a4a2cb53bd174ade53e898dae325095b50440b59fb6996e4bd0650c49b1ee5fcd6fbca8fd38dd5089b82030864494e95b29f7c76
        HEAD_REF main
    )
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDXC_ENABLE_HOST_TOOLS=OFF
        "-DLLVM_TABLEGEN=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/directx-dxc-tblgen/llvm-tblgen${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DCLANG_TABLEGEN=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/directx-dxc-tblgen/clang-tblgen${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -DHLSL_OPTIONAL_PROJS_IN_DEFAULT=OFF
        -DHLSL_ENABLE_ANALYZE=OFF
        -DHLSL_OFFICIAL_BUILD=OFF
        -DHLSL_ENABLE_FIXED_VER=OFF
        -DHLSL_BUILD_DXILCONV=OFF
        -DHLSL_INCLUDE_TESTS=OFF
        -DHLSL_ENABLE_DEBUG_ITERATORS=ON
        -DENABLE_SPIRV_CODEGEN=OFF
        -DSPIRV_BUILD_TESTS=OFF
        -DLLVM_BUILD_INSTRUMENTED_COVERAGE=OFF
        -DLLVM_BUILD_RUNTIME=ON
        -DLLVM_BUILD_EXAMPLES=OFF
        -DLLVM_BUILD_TESTS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_INCLUDE_DOCS=OFF
        -DLLVM_INCLUDE_EXAMPLES=OFF
        -DLLVM_OPTIMIZED_TABLEGEN=OFF
        -DLLVM_APPEND_VC_REV=OFF
        -DLLVM_ENABLE_RTTI=ON
        -DLLVM_ENABLE_EH=ON
        -DLLVM_ENABLE_TERMINFO=OFF
        -DLLVM_TARGETS_TO_BUILD=None
        -DLLVM_DEFAULT_TARGET_TRIPLE=dxil-ms-dx
        -DCLANG_CL=OFF
        -DCLANG_ENABLE_STATIC_ANALYZER=OFF
        -DCLANG_ENABLE_ARCMT=OFF
        -DCLANG_BUILD_EXAMPLES=OFF
        -DCLANG_INCLUDE_TESTS=OFF
        -DLIBCLANG_BUILD_STATIC=ON
    MAYBE_UNUSED_VARIABLES
        CLANG_CL
)

vcpkg_cmake_build(TARGET "dxildll;dxcompiler;dxc;dxv")

set(BUILD_DBG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(BUILD_REL_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

if(NOT EXISTS "${BUILD_REL_DIR}")
    message(FATAL_ERROR "${BUILD_REL_DIR} is not exists")
endif()

file(INSTALL
    "${SOURCE_PATH}/include/dxc/dxcapi.h"
    "${SOURCE_PATH}/include/dxc/dxcerrors.h"
    "${SOURCE_PATH}/include/dxc/dxcisense.h"
    "${SOURCE_PATH}/include/dxc/dxcpix.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc"
)
if(VCPKG_TARGET_IS_WINDOWS)
    set(Z_VCPKG_DXC_TARGET_IS_WINDOWS ON)

    if(EXISTS "${BUILD_DBG_DIR}")
        file(INSTALL
            "${BUILD_DBG_DIR}/bin/dxil.dll"
            "${BUILD_DBG_DIR}/bin/dxil.pdb"
            "${BUILD_DBG_DIR}/bin/dxcompiler.dll"
            "${BUILD_DBG_DIR}/bin/dxcompiler.pdb"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
        )
        file(INSTALL
            "${BUILD_DBG_DIR}/lib/dxil.lib"
            "${BUILD_DBG_DIR}/lib/dxcompiler.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()

    file(INSTALL
        "${BUILD_REL_DIR}/bin/dxil.dll"
        "${BUILD_REL_DIR}/bin/dxil.pdb"
        "${BUILD_REL_DIR}/bin/dxcompiler.dll"
        "${BUILD_REL_DIR}/bin/dxcompiler.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    )
    file(INSTALL
        "${BUILD_REL_DIR}/lib/dxil.lib"
        "${BUILD_REL_DIR}/lib/dxcompiler.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )

    file(INSTALL
        "${BUILD_REL_DIR}/bin/dxil.dll"
        "${BUILD_REL_DIR}/bin/dxcompiler.dll"
        "${BUILD_REL_DIR}/bin/dxc.exe"
        "${BUILD_REL_DIR}/bin/dxv.exe"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
else()
    set(Z_VCPKG_DXC_TARGET_IS_WINDOWS OFF)

    file(INSTALL
        "${SOURCE_PATH}/include/dxc/WinAdapter.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc"
    )

    if(EXISTS "${BUILD_DBG_DIR}")
        file(INSTALL
            "${BUILD_DBG_DIR}/lib/libdxil.so"
            "${BUILD_DBG_DIR}/lib/libdxcompiler.so"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()

    file(INSTALL
        "${BUILD_REL_DIR}/lib/libdxil.so"
        "${BUILD_REL_DIR}/lib/libdxcompiler.so"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
    )

    file(INSTALL
        "${BUILD_REL_DIR}/bin/dxc"
        "${BUILD_REL_DIR}/bin/dxv"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        USE_SOURCE_PERMISSIONS
    )
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/directx-dxc-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
