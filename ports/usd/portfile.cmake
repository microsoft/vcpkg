# USD plugins do not produce .lib
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

# Proper support for a true static usd build is left as a future port improvement.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REGEX REPLACE "^([0-9]+)[.]([0-9])\$" "\\1.0\\2" USD_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/OpenUSD
    REF "v${USD_VERSION}"
    SHA512 7d4404980579c4de3c155386184ca9d2eb96756ef6e090611bae7b4c21ad942c649f73a39b74ad84d0151ce6b9236c4b6c0c555e8e36fdd86304079e1c2e5cbe
    HEAD_REF release
    PATCHES
        001-fix_rename_find_package_to_find_dependency.patch # See PixarAnimationStudios/OpenUSD#3205
        002-vcpkg_find_tbb.patch # See PixarAnimationStudios/OpenUSD#3207
        003-vcpkg_find_opensubdiv.patch
        004-vcpkg_find_openimageio.patch
        005-vcpkg_find_shaderc.patch
        006-vcpkg_find_spirv-reflect.patch
        007-vcpkg_find_vma.patch
        008-fix_cmake_package.patch
        009-fix_cmake_hgi_interop.patch
        010-fix_missing_find_dependency_vulkan.patch
        011-fix_clang8_compiler_error.patch
        012-vcpkg_install_folder_conventions.patch
        013-cmake_export_plugin_as_modules.patch
        014-MaterialX_v1.38-39.patch # PixarAnimationStudios/OpenUSD#3159
        015-fix_missing_find_dependency_opengl.patch
        016-TBB-2022.patch # Accomodate oneapi-src/oneTBB#1345 changes
)

# Changes accompanying 006-vcpkg_find_spirv-reflect.patch
vcpkg_replace_string("${SOURCE_PATH}/pxr/imaging/hgiVulkan/shaderCompiler.cpp"
    [[#include "pxr/imaging/hgiVulkan/spirv_reflect.h"]]
    [[#include <spirv_reflect.h>]]
)
file(REMOVE
    "${SOURCE_PATH}/pxr/imaging/hgiVulkan/spirv_reflect.cpp"
    "${SOURCE_PATH}/pxr/imaging/hgiVulkan/spirv_reflect.h"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        materialx      PXR_ENABLE_MATERIALX_SUPPORT
        metal          PXR_ENABLE_METAL_SUPPORT
        openimageio    PXR_BUILD_OPENIMAGEIO_PLUGIN
        vulkan         PXR_ENABLE_VULKAN_SUPPORT
)

if (PXR_ENABLE_MATERIALX_SUPPORT)
    list(APPEND FEATURE_OPTIONS "-DMaterialX_DIR=${CURRENT_INSTALLED_DIR}/share/materialx")
endif()

# hgiInterop Metal and Vulkan backend requires garch which is only enabled if PXR_ENABLE_GL_SUPPORT is ON
if(PXR_ENABLE_VULKAN_SUPPORT OR PXR_ENABLE_METAL_SUPPORT)
    list(APPEND FEATURE_OPTIONS "-DPXR_ENABLE_GL_SUPPORT:BOOL=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DPXR_ENABLE_GL_SUPPORT:BOOL=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DPXR_BUILD_DOCUMENTATION:BOOL=OFF
        -DPXR_BUILD_EXAMPLES:BOOL=OFF
        -DPXR_BUILD_TESTS:BOOL=OFF
        -DPXR_BUILD_TUTORIALS:BOOL=OFF
        -DPXR_BUILD_USD_TOOLS:BOOL=OFF

        -DPXR_BUILD_ALEMBIC_PLUGIN:BOOL=OFF
        -DPXR_BUILD_DRACO_PLUGIN:BOOL=OFF
        -DPXR_BUILD_EMBREE_PLUGIN:BOOL=OFF
        -DPXR_BUILD_PRMAN_PLUGIN:BOOL=OFF

        -DPXR_BUILD_IMAGING:BOOL=ON 
        -DPXR_BUILD_USD_IMAGING:BOOL=ON 

        -DPXR_ENABLE_OPENVDB_SUPPORT:BOOL=OFF
        -DPXR_ENABLE_PTEX_SUPPORT:BOOL=OFF

        -DPXR_PREFER_SAFETY_OVER_SPEED:BOOL=ON 

        -DPXR_ENABLE_PRECOMPILED_HEADERS:BOOL=OFF

        -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF
        -DPXR_USE_DEBUG_PYTHON:BOOL=OFF
    MAYBE_UNUSED_VARIABLES
        PXR_USE_PYTHON_3
        PYTHON_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle debug path for USD plugins
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB_RECURSE debug_targets
        "${CURRENT_PACKAGES_DIR}/debug/share/pxr/*-debug.cmake"
        )
    foreach(debug_target IN LISTS debug_targets)
        file(READ "${debug_target}" contents)
        string(REPLACE "\${_IMPORT_PREFIX}/usd" "\${_IMPORT_PREFIX}/debug/usd" contents "${contents}")
        string(REPLACE "\${_IMPORT_PREFIX}/plugin" "\${_IMPORT_PREFIX}/debug/plugin" contents "${contents}")
        file(WRITE "${debug_target}" "${contents}")
    endforeach()
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME "pxr")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Move all dlls to bin
    file(GLOB RELEASE_DLL ${CURRENT_PACKAGES_DIR}/lib/*.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(GLOB DEBUG_DLL ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    foreach(CURRENT_FROM ${RELEASE_DLL} ${DEBUG_DLL})
        string(REPLACE "/lib/" "/bin/" CURRENT_TO ${CURRENT_FROM})
        file(RENAME ${CURRENT_FROM} ${CURRENT_TO})
    endforeach()

    function(file_replace_regex filename match_string replace_string)
        file(READ ${filename} _contents)
        string(REGEX REPLACE "${match_string}" "${replace_string}" _contents "${_contents}")
        file(WRITE ${filename} "${_contents}")
    endfunction()

    # fix dll path for cmake
    file_replace_regex(${CURRENT_PACKAGES_DIR}/share/pxr/pxrTargets-debug.cmake "debug/lib/([a-zA-Z0-9_]+)\\.dll" "debug/bin/\\1.dll")
    file_replace_regex(${CURRENT_PACKAGES_DIR}/share/pxr/pxrTargets-release.cmake "lib/([a-zA-Z0-9_]+)\\.dll" "bin/\\1.dll")

    # fix plugInfo.json for runtime
    file(GLOB_RECURSE PLUGINFO_FILES ${CURRENT_PACKAGES_DIR}/lib/usd/*/resources/plugInfo.json)
    file(GLOB_RECURSE PLUGINFO_FILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/usd/*/resources/plugInfo.json)
    foreach(PLUGINFO ${PLUGINFO_FILES} ${PLUGINFO_FILES_DEBUG})
        file_replace_regex(${PLUGINFO} [=["LibraryPath": "../../([a-zA-Z0-9_]+).dll"]=] [=["LibraryPath": "../../../bin/\1.dll"]=])
    endforeach()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.txt)
