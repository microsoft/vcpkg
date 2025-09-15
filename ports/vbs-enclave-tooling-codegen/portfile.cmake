set(ARCHIVE_FILENAME vbs-enclave-tooling-codegen-${VERSION}.tar.gz)
vcpkg_download_distfile(ARCHIVE
    # Use the VbsEnclaveTooling public nuget feed so internal Microsoft users as well as the public can access it in their pipelines.
    URLS "https://pkgs.dev.azure.com/shine-oss/VbsEnclaveTooling/_apis/packaging/feeds/VbsEnclaveToolingDependencies/nuget/packages/Microsoft.Windows.VbsEnclave.CodeGenerator/versions/${VERSION}/content?api-version=7.1-preview.1"
    FILENAME "${ARCHIVE_FILENAME}"
    SHA512 afba1a0d66299c412f15e8677479d72443a85913a335e3540eae517fc9e29c04c615470b9350b71fe9f73964e7ae5001a862383a76c548c4edfd5c8ae8832f7d
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE ${LIB_VERSION}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL
    "${PACKAGE_PATH}/src/VbsEnclaveABI"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

file(INSTALL
    "${PACKAGE_PATH}/src/wil"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    FILES_MATCHING PATTERN "*.h"
)

# veil_enclave_cpp_support lib contains CRT stubs and should not be autolinked globally to avoid symbol conflicts.
set(ENCLAVE_CPP_SUPPORT_DIR "${CURRENT_PACKAGES_DIR}/lib/manual-link")
set(ENCLAVE_CPP_SUPPORT_DEBUG_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")

file(INSTALL 
    "${PACKAGE_PATH}/lib/native/${VCPKG_TARGET_ARCHITECTURE}/"
    DESTINATION "${ENCLAVE_CPP_SUPPORT_DIR}"
    FILES_MATCHING PATTERN "veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Release_lib.*"
)

file(INSTALL 
    "${PACKAGE_PATH}/lib/native/${VCPKG_TARGET_ARCHITECTURE}/"
    DESTINATION "${ENCLAVE_CPP_SUPPORT_DEBUG_DIR}"
    FILES_MATCHING PATTERN "veil_enclave_cpp_support_${VCPKG_TARGET_ARCHITECTURE}_Debug_lib.*"
)

vcpkg_copy_tools(TOOL_NAMES edlcodegen SEARCH_DIR "${PACKAGE_PATH}/bin" AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE")