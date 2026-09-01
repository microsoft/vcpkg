# Don't use vcpkg_from_github as the archive is much bigger than the headers only archive
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/GPUOpen-LibrariesAndSDKs/AMF/releases/download/v${VERSION}/AMF-headers-v${VERSION}.tar.gz"
    FILENAME "AMF-headers-v${VERSION}.tar.gz"
    SHA512 b992d4a1f59f7b1c789d03e7bd9876417a569fb239bfe2e2178f2434ae18653bbacc912de2b8a5f8ff0a85fad28b0c1091c2a8d3417407a37c22c1e907e4c159
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
