vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.7.2207/dxc_2022_07_18.zip"
    FILENAME "dxc_2022_07_18.zip"
    SHA512 b34d770ed9299e6a9ade12cd8d9add28f50e41abdfcdbc7e272568d7f78fe5a8f2bbe5f905839981b97d34b52e1fa627ceacd55743f2cf71e39861418b11ae3b
)

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/v1.7.2207/LICENSE.TXT"
    FILENAME "LICENSE.v1.7.2207"
    SHA512 7589f152ebc3296dca1c73609a2a23a911b8fc0029731268a6151710014d82005a868c85c8249219f060f64ab1ddecdddff5ed6ea34ff509f63ea3e42bbbf47e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(DXC_ARCH arm64)
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
