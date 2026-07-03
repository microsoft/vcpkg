set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/DirectXShaderCompiler
    REF e39cf36f5b2a171000a3a1134dadc9f454ff54cf
    SHA512 143f560ec7d8753ea1795fe7b2922823a6f1dcaf2becbd1a88b1a3fd9ce2da006072d8d1c318b834ea4b6344d3ec71d8d8f5b8870e06282fbb5352d16d7ca1cb
    HEAD_REF main
    PATCHES
      # Update this patch file when update version
      002-fix-gen-version-inc.patch
      003-fix-python.patch
)

function(checkout_in_path PATH URL REF)
    cmake_parse_arguments(EXTERNAL "" "" "PATCHES" ${ARGN})
    if(EXISTS "${PATH}")
        file(GLOB_RECURSE subdirectory_children "${CURRENT_PACKAGES_DIR}/include/${directory_child}/*")
        if(NOT "${subdirectory_children}" STREQUAL "")
            return()
        else()
            file(REMOVE_RECURSE "${PATH}")
        endif()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        PATCHES ${EXTERNAL_PATCHES}
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    checkout_in_path(
        "${SOURCE_PATH}/external/DirectX-Headers"
        "https://github.com/microsoft/DirectX-Headers"
        "980971e835876dc0cde415e8f9bc646e64667bf7"
    )

    checkout_in_path(
        "${SOURCE_PATH}/external/SPIRV-Headers"
        "https://github.com/KhronosGroup/SPIRV-Headers"
        "ad9184e76a66b1001c29db9b0a3e87f646c64de0"
    )

    checkout_in_path(
        "${SOURCE_PATH}/external/SPIRV-Tools"
        "https://github.com/KhronosGroup/SPIRV-Tools"
        "0539c81f69a3daeb706fd3477dca61435b475156"
    )
endif()

vcpkg_find_acquire_program(PYTHON3)

# This port requires BUILD_SHARED_LIBS=OFF
set(VCPKG_LIBRARY_LINKAGE_BACKUP ${VCPKG_LIBRARY_LINKAGE})
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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

vcpkg_cmake_build()

# Restore the original library linkage
set(VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE_BACKUP})

set(BUILD_DBG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(BUILD_REL_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

if(NOT EXISTS "${BUILD_REL_DIR}")
    message(FATAL_ERROR "${BUILD_REL_DIR} is not exists")
endif()

file(INSTALL "${SOURCE_PATH}/include/dxc/dxcapi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc")
file(INSTALL "${SOURCE_PATH}/include/dxc/dxcerrors.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc")
file(INSTALL "${SOURCE_PATH}/include/dxc/dxcisense.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc")
file(INSTALL "${SOURCE_PATH}/include/dxc/dxcpix.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc")
if(VCPKG_TARGET_IS_WINDOWS)
    set(Z_VCPKG_DXC_TARGET_IS_WINDOWS ON)

    if (EXISTS "${BUILD_DBG_DIR}")
        file(INSTALL "${BUILD_DBG_DIR}/bin/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${BUILD_DBG_DIR}/bin/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${BUILD_DBG_DIR}/bin/dxil.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${BUILD_DBG_DIR}/bin/dxcompiler.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${BUILD_DBG_DIR}/lib/dxil.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(INSTALL "${BUILD_DBG_DIR}/lib/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()

    file(INSTALL "${BUILD_REL_DIR}/bin/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxil.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxcompiler.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${BUILD_REL_DIR}/lib/dxil.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${BUILD_REL_DIR}/lib/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    file(INSTALL "${BUILD_REL_DIR}/bin/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxc.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxv.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
else()
    set(Z_VCPKG_DXC_TARGET_IS_WINDOWS OFF)

    file(INSTALL "${SOURCE_PATH}/include/dxc/WinAdapter.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dxc")

    if (EXISTS "${BUILD_DBG_DIR}")
        file(INSTALL "${BUILD_DBG_DIR}/lib/libdxil.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(INSTALL "${BUILD_DBG_DIR}/lib/libdxcompiler.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()

    file(INSTALL "${BUILD_REL_DIR}/lib/libdxil.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${BUILD_REL_DIR}/lib/libdxcompiler.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    file(INSTALL "${BUILD_REL_DIR}/bin/dxc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(INSTALL "${BUILD_REL_DIR}/bin/dxv" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/directx-dxc-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
