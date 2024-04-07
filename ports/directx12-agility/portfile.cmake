set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.D3D12/${VERSION}"
    FILENAME "Microsoft.Direct3D.D3D12.${VERSION}.zip"
    SHA512 9703445beb09808f1edf1320605d870fdfbd74b728227df2c9c99a560400c653f38960b6f54f45dc36fcb2609acb412d30307391ee02df53bc636e2c4c89f22c
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(REDIST_ARCH win32)
else()
    set(REDIST_ARCH ${VCPKG_TARGET_ARCHITECTURE})
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

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx12-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)
