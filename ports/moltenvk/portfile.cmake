vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KhronosGroup/MoltenVK/releases/download/v${VERSION}/MoltenVK-macos.tar"
    FILENAME "MoltenVK-macos.tar"
    SHA512 f711c91ef0933cfa1916f92a6aa4611ca990c0e2240020b0007f0c3dee47e7ba0547c6da6e17fd9420026ec9651ce9ea7679d7d22544b8fb90469ef39dd74a2b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(INSTALL "${SOURCE_PATH}/MoltenVK/include/MoltenVK" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL "${SOURCE_PATH}/MoltenVK/dylib/macOS/libMoltenVK.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")
    file(INSTALL "${SOURCE_PATH}/MoltenVK/dylib/macOS/MoltenVK_icd.json" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")
else()
    file(INSTALL "${SOURCE_PATH}/MoltenVK/MoltenVK.xcframework/macos-arm64_x86_64/libMoltenVK.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
