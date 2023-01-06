set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

if (NOT VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
   message(STATUS "Note: ${PORT} always requires dynamic library linkage at runtime.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.7.2212/dxc_2022_12_16.zip"
    FILENAME "dxc_2022_12_16.zip"
    SHA512 b4885bdec0db5b6385d4a8c06617051b1777002c3f39bfcf4c9d2c95e9491634f0e77a18375bf5be5152136c5f509a94e3b4a9c56d2e844316e8b760b6acaf68
)

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/v1.7.2212/LICENSE.TXT"
    FILENAME "LICENSE.v1.7.2212"
    SHA512 7589f152ebc3296dca1c73609a2a23a911b8fc0029731268a6151710014d82005a868c85c8249219f060f64ab1ddecdddff5ed6ea34ff509f63ea3e42bbbf47e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(DXC_ARCH arm64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(DXC_ARCH x86)
else()
    set(DXC_ARCH x64)
endif()

file(INSTALL "${PACKAGE_PATH}/inc/d3d12shader.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${PACKAGE_PATH}/inc/dxcapi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${PACKAGE_PATH}/lib/${DXC_ARCH}/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

file(COPY "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(COPY "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

file(INSTALL
  "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxc.exe"
  "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxcompiler.dll"
  "${PACKAGE_PATH}/bin/${DXC_ARCH}/dxil.dll"
  DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${LICENSE_TXT}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
