vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF d6c9a6560265025a30d16fcd9d664f830ab63109
    SHA512 d6161a317ca0fd3cf8c782f058fc43765d611b5f6a8e82da736f5164a0e1829a46f75e376715fcb7cb9521406365aa88880ed44235b2bf63899affcc5bd54091
    HEAD_REF master
    PATCHES
        001-freeimage-from-vcpkg.patch
        002-clang-7.0.x-and-above.patch
        003-install-rules.patch
        004-freeimage-disable-faxg3.patch
        005-missing-std-includes.patch
        006-missing-link-windows-crypt-libraries.patch
        007-guard-nonexisting-targets.patch
        008-plugin-options.patch
        009-build-static-llvm.patch
)

string(COMPARE NOTEQUAL "${VCPKG_CRT_LINKAGE}" "static" _MVSC_CRT_LINKAGE_OPTION)

vcpkg_find_acquire_program(PYTHON3)
set(PATH_PYTHON ${PYTHON3})

vcpkg_find_acquire_program(CLANG)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dds MDL_BUILD_DDS_PLUGIN
        freeimage MDL_BUILD_FREEIMAGE_PLUGIN)

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
        
        -Dclang_PATH:PATH=${CLANG}
        -Dpython_PATH:PATH=${PATH_PYTHON}

        ${FEATURE_OPTIONS}
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
