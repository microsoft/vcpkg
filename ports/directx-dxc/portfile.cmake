set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

set(DIRECTX_DXC_TAG v1.7.2212.1)
set(DIRECTX_DXC_VERSION 2023_03_01)

if (NOT VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
   message(STATUS "Note: ${PORT} always requires dynamic library linkage at runtime.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/linux_dxc_${DIRECTX_DXC_VERSION}.x86_64.tar.gz"
        FILENAME "linux_dxc_${DIRECTX_DXC_VERSION}.tar.gz"
        SHA512 66b421377a92b8ebb700f5df30b538393b826e3f12bb3478430dbbb1f899e435f6ed8c442a38ef9218d6f55d6e5c0441bd8a766bc1960df278567e575f8b969c
    )
else()
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/${DIRECTX_DXC_TAG}/dxc_${DIRECTX_DXC_VERSION}.zip"
        FILENAME "dxc_${DIRECTX_DXC_VERSION}.zip"
        SHA512 9c348d24f406c5072a57961184d5f6c6d6483666bbb2f18dd31a9c666249e1b83e6c035dcdbdd126d084e4a5cbe0973cd823df97ac9b1efc715c15ce5691b27a
    )
endif()

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/${DIRECTX_DXC_TAG}/LICENSE.TXT"
    FILENAME "LICENSE.${DIRECTX_DXC_VERSION}"
    SHA512 7589f152ebc3296dca1c73609a2a23a911b8fc0029731268a6151710014d82005a868c85c8249219f060f64ab1ddecdddff5ed6ea34ff509f63ea3e42bbbf47e
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
  file(INSTALL
    "${PACKAGE_PATH}/lib/libdxcompiler.so"
    "${PACKAGE_PATH}/lib/libdxil.so"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

  file(INSTALL
    "${PACKAGE_PATH}/bin/dxc"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

  set(dll_name "libdxcompiler.so")
  set(dll_dir  "lib")
  set(lib_name "libdxcompiler.so")
  set(tool_path "bin/dxc")
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
  file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

  file(INSTALL
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
  file(INSTALL
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

  file(INSTALL
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxc.exe"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
    "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

  set(dll_name "dxcompiler.dll")
  set(dll_dir  "bin")
  set(lib_name "dxcompiler.lib")
  set(tool_path "tools/directx-dxc/dxc.exe")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${LICENSE_TXT}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)
