set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # headers are provided by the directx-headers port
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # DX12 SDK Debug Layer is an extra DLL

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.D3D12/${VERSION}"
    FILENAME "Microsoft.Direct3D.D3D12.${VERSION}.zip"
    SHA512 a88be98bb043528c66018e960915a95567e99dbdd06a8fd8811d58c0302630f8faa881fde35f9a7eaac437c42b93f130001054d2b6e57488f59f26f0eb831325
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(REDIST_ARCH arm64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(REDIST_ARCH win32)
else()
    set(REDIST_ARCH x64)
endif()

file(COPY "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/D3D12Core.dll" "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/D3D12Core.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

file(COPY "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/D3D12Core.dll" "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/D3D12Core.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(COPY "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/d3d12SDKLayers.dll" "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/d3d12SDKLayers.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(COPY "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/d3dconfig.exe" "${PACKAGE_PATH}/build/native/bin/${REDIST_ARCH}/d3dconfig.pdb"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools//${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")

message(STATUS "BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS: https://www.nuget.org/packages/Microsoft.Direct3D.D3D12/${VERSION}/License")

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx12-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)
