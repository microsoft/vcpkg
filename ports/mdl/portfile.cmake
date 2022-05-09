
vcpkg_check_linkage(
    ONLY_DYNAMIC_LIBRARY
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF d51e97f0019642f0cb1dfb7b67a4edaac2058f92
    SHA512 585a58cd2f1dcf9c8e72dcfef57db8808b9ca4427e6914df3fee6f295d977b7f771531c3c275d54be3ec6c64fc1acfe7c7a4f6608bcf0831e11df6d9d5632ca3
    HEAD_REF master
    PATCHES
        001-freeimage-from-vcpkg.patch
        002-clang-7.0.x-and-above.patch
        003-install-rules.patch
        004-freeimage-disable-faxg3.patch
        005-missing-std-includes.patch
        006-missing-link-windows-crypt-libraries.patch
        007-guard-nonexisting-targets.patch
        008-disable-plugins.patch
        009-build-static-llvm.patch
)

string(COMPARE NOTEQUAL "${VCPKG_CRT_LINKAGE}" "static" _MVSC_CRT_LINKAGE_OPTION)

vcpkg_find_acquire_program(PYTHON3)
set(PATH_PYTHON ${PYTHON3})

vcpkg_find_acquire_program(CLANG)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMDL_MSVC_DYNAMIC_RUNTIME_EXAMPLES:BOOL=${_MVSC_CRT_LINKAGE_OPTION}

        -DMDL_ENABLE_CUDA_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPENGL_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_QT_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_D3D12_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPTIX7_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_MATERIALX:BOOL=OFF

        -DMDL_BUILD_SDK_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_CORE_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_ARNOLD_PLUGIN:BOOL=OFF
        
        -DMDL_INSTALL_PLUGINS:BOOL=OFF

        -Dclang_PATH:PATH=${CLANG}
        -Dpython_PATH:PATH=${PATH_PYTHON}
    OPTIONS_DEBUG
        -DMDL_INSTALL_HEADERS:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_copy_tools(
    TOOL_NAMES i18n mdlc mdlm
    AUTO_CLEAN
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
