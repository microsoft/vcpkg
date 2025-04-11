set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

set(DIRECTX_DXC_TAG 1.8.2502)
set(DIRECTX_DXC_VERSION 2025_02_20)

# for macOS platform:
# The DirectX Headers module seems not working with the latest version
# Therefore we manually download the specific version according to the original DXC repo
# https://github.com/microsoft/DirectXShaderCompiler/tree/release-1.8.2502/external
set(DX_HEADERS_MODULE_HASH 980971e835876dc0cde415e8f9bc646e64667bf7)

if (NOT VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
   message(STATUS "Note: ${PORT} always requires dynamic library linkage at runtime.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v${DIRECTX_DXC_TAG}/linux_dxc_${DIRECTX_DXC_VERSION}.x86_64.tar.gz"
        FILENAME "linux_dxc_${DIRECTX_DXC_VERSION}.tar.gz"
        SHA512 48d246349a7b8c998d80969a3d0a383c9fd287c7130c0ea3b214a2e8630d36ac38b78c1263a954777d89760910092f7a9812d421784706efa182cefeb017c3c6
    )
elseif (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v${DIRECTX_DXC_TAG}/dxc_${DIRECTX_DXC_VERSION}.zip"
        FILENAME "dxc_${DIRECTX_DXC_VERSION}.zip"
        SHA512 2381852e0d57be65ab919df00d79cda3564cd3695c6415065680738b66de1fc106106baae322973c6a48337b97e603294ee5118f71559298b7097181e73e4b31
    )
elseif (VCPKG_TARGET_IS_OSX)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO "microsoft/DirectXShaderCompiler"
        REF "release-${DIRECTX_DXC_TAG}"
        PATCHES osx-config-and-install.patch
        SHA512 720301093c9e04c23518fdf50aec110bc1a4eafc9d585e73652b7db06c86185e0eca7dd75d4b97f13bdd4e6362ebc0ecc61a5a65f90e193a82dc0bbb48e09b3b
    )
    vcpkg_download_distfile(DX_HEADERS_ARCHIVE
        URLS "https://github.com/microsoft/DirectX-Headers/archive/${DX_HEADERS_MODULE_HASH}.zip"
        FILENAME "DirectX-Headers.zip"
        SHA512 b7f01f9bc3cf6f9600f6a75513e62fcf65d719ca0addac216ec3c1e498696b945146c855097868d0a16e3764278710dcb092748e2dd70fcfe25f4373fae51f63
    )
endif ()

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/v${DIRECTX_DXC_TAG}/LICENSE.TXT"
    FILENAME "LICENSE.${DIRECTX_DXC_VERSION}"
    SHA512  9feaa85ca6d42d5a2d6fe773706bbab8241e78390a9d61ea9061c8f0eeb5a3e380ff07c222e02fbf61af7f2b2f6dd31c5fc87247a94dae275dc0a20cdfcc8c9d
)

if (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive(
        PACKAGE_PATH
        ARCHIVE ${ARCHIVE}
        NO_REMOVE_ONE_LEVEL
    )
else ()
    vcpkg_extract_source_archive(
            DX_HEADERS_PATH
            ARCHIVE ${DX_HEADERS_ARCHIVE}
    )

    set(PACKAGE_PATH ${CURRENT_BUILDTREES_DIR}/inst)
    vcpkg_cmake_configure(
            SOURCE_PATH ${SOURCE_PATH}
            OPTIONS
            "-C ${SOURCE_PATH}/cmake/caches/PredefinedParams.cmake"
            "-DDIRECTX_HEADER_INCLUDE_DIR=${DX_HEADERS_PATH}/include"
            "-DCMAKE_INSTALL_PREFIX=${PACKAGE_PATH}"
    )
    vcpkg_cmake_build(TARGET install-distribution)
endif ()


if (VCPKG_TARGET_IS_LINUX)
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

  if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL
      "${PACKAGE_PATH}/lib/libdxcompiler.so"
      "${PACKAGE_PATH}/lib/libdxil.so"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()

  file(INSTALL
    "${PACKAGE_PATH}/bin/dxc"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/"
    FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE)

  set(dll_name_dxc "libdxcompiler.so")
  set(dll_name_dxil "libdxil.so")
  set(dll_dir  "lib")
  set(lib_name "libdxcompiler.so")
  set(tool_path "tools/${PORT}/dxc")
elseif (VCPKG_TARGET_IS_WINDOWS)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
      set(DXC_ARCH arm64)
  elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
      set(DXC_ARCH x86)
  else()
      set(DXC_ARCH x64)
  endif()

  file(INSTALL
    "${PACKAGE_PATH}/inc/dxcapi.h"
    "${PACKAGE_PATH}/inc/dxcerrors.h"
    "${PACKAGE_PATH}/inc/dxcisense.h"
    "${PACKAGE_PATH}/inc/d3d12shader.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

  file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()

  file(INSTALL
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

  if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL
      "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
      "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
  endif()

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

  file(INSTALL
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxc.exe"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

  set(dll_name_dxc "dxcompiler.dll")
  set(dll_name_dxil "dxil.dll")
  set(dll_dir  "bin")
  set(lib_name "dxcompiler.lib")
  set(tool_path "tools/${PORT}/dxc.exe")
elseif (VCPKG_TARGET_IS_OSX)
  file(INSTALL
    "${PACKAGE_PATH}/include/dxc/dxcapi.h"
    "${PACKAGE_PATH}/include/dxc/dxcerrors.h"
    "${PACKAGE_PATH}/include/dxc/dxcisense.h"
    "${PACKAGE_PATH}/include/dxc/WinAdapter.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

  file(INSTALL
    "${PACKAGE_PATH}/lib/libdxcompiler.dylib"
    "${PACKAGE_PATH}/lib/libdxil.dylib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

  if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL
      "${PACKAGE_PATH}/lib/libdxcompiler.dylib"
      "${PACKAGE_PATH}/lib/libdxil.dylib"
      DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()

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
endif ()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${LICENSE_TXT}")
