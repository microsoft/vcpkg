vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.6.2112/dxc_2021_12_08.zip"
    FILENAME "dxc_2021_12_08.zip"
    SHA512 e9b36e896c1d47b39b648adbecf44da7f8543216fd1df539760f0c591907aea081ea6bfc59eb927073aaa1451110c5dc63003546509ff84c9e4445488df97c27
)

vcpkg_download_distfile(
    LICENSE_TXT
    URLS "https://raw.githubusercontent.com/microsoft/DirectXShaderCompiler/v1.6.2112/LICENSE.TXT"
    FILENAME "LICENSE.v1.6.2112"
    SHA512 7589f152ebc3296dca1c73609a2a23a911b8fc0029731268a6151710014d82005a868c85c8249219f060f64ab1ddecdddff5ed6ea34ff509f63ea3e42bbbf47e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${PACKAGE_PATH}/inc/d3d12shader.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${PACKAGE_PATH}/inc/dxcapi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(INSTALL "${PACKAGE_PATH}/lib/x64/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${PACKAGE_PATH}/lib/x64/dxcompiler.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

file(COPY "${PACKAGE_PATH}/bin/x64/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/bin/x64/dxcompiler.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(COPY "${PACKAGE_PATH}/bin/x64/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/bin/x64/dxil.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

file(INSTALL
  "${PACKAGE_PATH}/bin/x64/dxc.exe"
  "${PACKAGE_PATH}/bin/x64/dxcompiler.dll"
  "${PACKAGE_PATH}/bin/x64/dxil.dll"
  DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${LICENSE_TXT}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/directx-dxc-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
