vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF d6c9a6560265025a30d16fcd9d664f830ab63109
    SHA512 d6161a317ca0fd3cf8c782f058fc43765d611b5f6a8e82da736f5164a0e1829a46f75e376715fcb7cb9521406365aa88880ed44235b2bf63899affcc5bd54091
    HEAD_REF master
    PATCHES
        001-freeimage-from-vcpkg.patch
        002-use-llvm-clang.patch
        003-install-rules.patch
        004-freeimage-disable-faxg3.patch
        005-missing-std-includes.patch
        006-missing-link-windows-crypt-libraries.patch
        007-guard-nonexisting-targets.patch
        008-plugin-options.patch
        009-build-static-llvm.patch
)

if(NOT EXISTS "${SOURCE_PATH}/src/mdl/jit/llvm/dist/tools/clang")
    vcpkg_download_distfile(CLANG_ARCHIVE
        URLS "http://releases.llvm.org/7.0.0/cfe-7.0.0.src.tar.xz"
        FILENAME "cfe-7.0.0.src.tar.xz"
        SHA512 17a658032a0160c57d4dc23cb45a1516a897e0e2ba4ebff29472e471feca04c5b68cff351cdf231b42aab0cff587b84fe11b921d1ca7194a90e6485913d62cb7
    )
    vcpkg_extract_source_archive(CLANG_SOURCE_PATH
        ARCHIVE "${CLANG_ARCHIVE}"
        PATCHES
            001-clang-skip-symlink.patch
            002-clang-build-static-clang.patch)
    file(RENAME "${CLANG_SOURCE_PATH}" "${SOURCE_PATH}/src/mdl/jit/llvm/dist/tools/clang")
endif()

string(COMPARE NOTEQUAL "${VCPKG_CRT_LINKAGE}" "static" _MVSC_CRT_LINKAGE_OPTION)

vcpkg_find_acquire_program(PYTHON3)
set(PATH_PYTHON ${PYTHON3})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dds MDL_BUILD_DDS_PLUGIN
        freeimage MDL_BUILD_FREEIMAGE_PLUGIN)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-mdl-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMDL_LOG_DEPENDENCIES:BOOL=ON

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
        
        -Dpython_PATH:PATH=${PATH_PYTHON}

        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mdl)
vcpkg_copy_tools(
    TOOL_NAMES i18n mdlc mdlm
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
