set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

set(DIRECTX_DXC_TAG v1.9.2602.24)
set(DIRECTX_DXC_VERSION 2026_05_27)
set(DIRECTX_DXC_VERSION_WSL 2026_05_26)

if (NOT VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
   message(STATUS "Note: ${PORT} always requires dynamic library linkage at runtime.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/linux_dxc_${DIRECTX_DXC_VERSION_WSL}.x86_64.tar.gz"
        FILENAME "linux_dxc_${DIRECTX_DXC_VERSION_WSL}.tar.gz"
        SHA512 3da18b4b32899c65881276315411092fa1a076e25bbea20606bc247c5fa93c83f948785969e007115dc72afcd433ab76e54c392de6d37c11d93d8614a829e40a
    )
else()
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/dxc_${DIRECTX_DXC_VERSION}.zip"
        FILENAME "dxc_${DIRECTX_DXC_VERSION}.zip"
        SHA512 cf331112f1753fca68525c85bb4964714d85dbf7cb5e41af4720bbdffefdfddad1878c7a1a74898e2105dff32957a526d188d9ee3f18f0df310ec8548827a374
    )
endif()

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/${DIRECTX_DXC_TAG}/LICENSE.TXT"
    FILENAME "LICENSE.${DIRECTX_DXC_VERSION}"
    SHA512  9feaa85ca6d42d5a2d6fe773706bbab8241e78390a9d61ea9061c8f0eeb5a3e380ff07c222e02fbf61af7f2b2f6dd31c5fc87247a94dae275dc0a20cdfcc8c9d
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

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
  if(NOT DEFINED VCPKG_BUILD_TYPE)
    set(dll_debug_dir "debug/lib")
  else()
    set(dll_debug_dir "lib")
  endif()
  set(lib_name "libdxcompiler.so")
  set(tool_path "tools/${PORT}/dxc")
else()
  # VCPKG_TARGET_IS_WINDOWS
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
  set(dll_debug_dir "bin")
  set(lib_name "dxcompiler.lib")
  set(tool_path "tools/${PORT}/dxc.exe")
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${LICENSE_TXT}")
