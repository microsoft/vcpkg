set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

set(DIRECTX_DXC_TAG v1.8.2502)
set(DIRECTX_DXC_VERSION 2025_02_20)

if (NOT VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Note: ${PORT} always requires dynamic library linkage at runtime.")
endif ()

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
            URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/linux_dxc_${DIRECTX_DXC_VERSION}.x86_64.tar.gz"
            FILENAME "linux_dxc_${DIRECTX_DXC_VERSION}.tar.gz"
            SHA512 48d246349a7b8c998d80969a3d0a383c9fd287c7130c0ea3b214a2e8630d36ac38b78c1263a954777d89760910092f7a9812d421784706efa182cefeb017c3c6
    )
elseif (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
            URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/dxc_${DIRECTX_DXC_VERSION}.zip"
            FILENAME "dxc_${DIRECTX_DXC_VERSION}.zip"
            SHA512 2381852e0d57be65ab919df00d79cda3564cd3695c6415065680738b66de1fc106106baae322973c6a48337b97e603294ee5118f71559298b7097181e73e4b31
    )
elseif (VCPKG_TARGET_IS_OSX)
    vcpkg_from_github(
            OUT_SOURCE_PATH SOURCE_PATH
            REPO "microsoft/DirectXShaderCompiler"
            REF "2399215226737c64e76afc55ffd874ecd6fc459f"
            SHA512 7fdc95859068f6d4cff8b73fe2c99f9305fce9ab8d7b6c212642c15d017b87084ac8f86a4b73aa9aa9d0519f2a0bf9ac851be0228636fc74dac6aa3e078bb880
    )
endif ()

vcpkg_download_distfile(
        LICENSE_TXT
        URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/${DIRECTX_DXC_TAG}/LICENSE.TXT"
        FILENAME "LICENSE.${DIRECTX_DXC_VERSION}"
        SHA512 9feaa85ca6d42d5a2d6fe773706bbab8241e78390a9d61ea9061c8f0eeb5a3e380ff07c222e02fbf61af7f2b2f6dd31c5fc87247a94dae275dc0a20cdfcc8c9d
)

if (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive(
            PACKAGE_PATH
            ARCHIVE ${ARCHIVE}
            NO_REMOVE_ONE_LEVEL
    )
else ()
    vcpkg_execute_required_process(
            COMMAND git clone https://github.com/microsoft/DirectX-Headers.git external/DirectX-Headers
            WORKING_DIRECTORY ${SOURCE_PATH}/
            LOGNAME fetch-submodule-dx-headers
    )
    vcpkg_execute_required_process(
            COMMAND git clone https://github.com/KhronosGroup/SPIRV-Headers.git external/SPIRV-Headers
            WORKING_DIRECTORY ${SOURCE_PATH}/
            LOGNAME fetch-submodule-spirv-headers
    )
    vcpkg_execute_required_process(
            COMMAND git clone https://github.com/KhronosGroup/SPIRV-Tools.git external/SPIRV-Tools
            WORKING_DIRECTORY ${SOURCE_PATH}/
            LOGNAME fetch-submodule-spirv-tools
    )
    vcpkg_execute_required_process(
            COMMAND git checkout 980971e835876dc0cde415e8f9bc646e64667bf7
            WORKING_DIRECTORY ${SOURCE_PATH}/external/DirectX-Headers
            LOGNAME checkout-submodule-dx-headers
    )
    vcpkg_execute_required_process(
            COMMAND git checkout 3f17b2af6784bfa2c5aa5dbb8e0e74a607dd8b3b
            WORKING_DIRECTORY ${SOURCE_PATH}/external/SPIRV-Headers
            LOGNAME checkout-submodule-spirv-headers
    )
    vcpkg_execute_required_process(
            COMMAND git checkout 4d2f0b40bfe290dea6c6904dafdf7fd8328ba346
            WORKING_DIRECTORY ${SOURCE_PATH}/external/SPIRV-Tools
            LOGNAME checkout-submodule-spirv-tools
    )
    vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH} OPTIONS "-C ${SOURCE_PATH}/cmake/caches/PredefinedParams.cmake")
    vcpkg_cmake_build()
endif ()

if (VCPKG_TARGET_IS_OSX)
    set(PACKAGE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    set(PACKAGE_PATH_DEBUG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    if (VCPKG_BUILD_TYPE STREQUAL "debug")
        set(PACKAGE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    endif ()

    file(INSTALL
            "${SOURCE_PATH}/include/dxc/dxcapi.h"
            "${SOURCE_PATH}/include/dxc/dxcerrors.h"
            "${SOURCE_PATH}/include/dxc/dxcisense.h"
            "${SOURCE_PATH}/include/dxc/WinAdapter.h"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

    file(INSTALL
            "${PACKAGE_PATH}/lib/libdxcompiler.dylib"
            "${PACKAGE_PATH}/lib/libdxil.dylib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    if (NOT DEFINED VCPKG_BUILD_TYPE)
        file(INSTALL
                "${PACKAGE_PATH}/lib/libdxcompiler.dylib"
                "${PACKAGE_PATH}/lib/libdxil.dylib"
                DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif ()

    file(INSTALL
            "${PACKAGE_PATH}/bin/dxc"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/"
            FILE_PERMISSIONS
            OWNER_READ OWNER_WRITE OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)

    set(dll_name_dxc "libdxcompiler.dylib")
    set(dll_name_dxil "libdxil.dylib")
    set(dll_dir "lib")
    set(lib_name "libdxcompiler.dylib")
    set(tool_path "tools/${PORT}/dxc")
elseif (VCPKG_TARGET_IS_LINUX)
    file(INSTALL
            "${PACKAGE_PATH}/include/dxc/dxcapi.h"
            "${PACKAGE_PATH}/include/dxc/dxcerrors.h"
            "${PACKAGE_PATH}/include/dxc/dxcisense.h"
            "${PACKAGE_PATH}/include/dxc/WinAdapter.h"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

    file(INSTALL
            "${PACKAGE_PATH}/lib/libdxcompiler.so"
            "${PACKAGE_PATH}/lib/libdxil.so"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    if (NOT DEFINED VCPKG_BUILD_TYPE)
        file(INSTALL
                "${PACKAGE_PATH}/lib/libdxcompiler.so"
                "${PACKAGE_PATH}/lib/libdxil.so"
                DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif ()

    file(INSTALL
            "${PACKAGE_PATH}/bin/dxc"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/"
            FILE_PERMISSIONS
            OWNER_READ OWNER_WRITE OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)

    set(dll_name_dxc "libdxcompiler.so")
    set(dll_name_dxil "libdxil.so")
    set(dll_dir "lib")
    set(lib_name "libdxcompiler.so")
    set(tool_path "tools/${PORT}/dxc")
elseif (VCPKG_TARGET_IS_WINDOWS)
    # VCPKG_TARGET_IS_WINDOWS
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(DXC_ARCH arm64)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(DXC_ARCH x86)
    else ()
        set(DXC_ARCH x64)
    endif ()

    file(INSTALL
            "${PACKAGE_PATH}/inc/dxcapi.h"
            "${PACKAGE_PATH}/inc/dxcerrors.h"
            "${PACKAGE_PATH}/inc/dxcisense.h"
            "${PACKAGE_PATH}/inc/d3d12shader.h"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

    file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT DEFINED VCPKG_BUILD_TYPE)
        file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif ()

    file(INSTALL
            "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
            "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
            DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

    if (NOT DEFINED VCPKG_BUILD_TYPE)
        file(INSTALL
                "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
                "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
                DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif ()

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

    file(INSTALL
            "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxc.exe"
            "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
            "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

    set(dll_name_dxc "dxcompiler.dll")
    set(dll_name_dxil "dxil.dll")
    set(dll_dir "bin")
    set(lib_name "dxcompiler.lib")
    set(tool_path "tools/${PORT}/dxc.exe")
endif ()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
        @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${LICENSE_TXT}")
