# Don't use vcpkg_from_github as the archive is much bigger than the headers only archive
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/GPUOpen-LibrariesAndSDKs/AMF/releases/download/v${VERSION}/AMF-headers-v${VERSION}.tar.gz"
    FILENAME "AMF-headers-v${VERSION}.tar.gz"
    SHA512 9841bffd15786a8baf115fb736b8ed0bbc1076ef59757a3676a7d509116690cb9775de41e25a63bac364a200192d6abbabe9203425392fddf112274335293f24
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Download license file
vcpkg_download_distfile(LICENSE_FILE
    URLS "https://raw.githubusercontent.com/GPUOpen-LibrariesAndSDKs/AMF/v${VERSION}/LICENSE.txt"
    FILENAME "LICENSE.txt"
    SHA512 6b3261e5f38179c0d96483e44b339933a8eb0d9324784953eed74dfe2658ab9d94a9afb09d85ac1138300c8272ac73fb5e1e1f56ea26312f572453fab86f228a
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/AMF/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${LICENSE_FILE}")
