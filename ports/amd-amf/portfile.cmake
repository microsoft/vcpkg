# Don't use vcpkg_from_github as the archive is much bigger than the headers only archive
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/GPUOpen-LibrariesAndSDKs/AMF/releases/download/v${VERSION}/AMF-headers-v${VERSION}.tar.gz"
    FILENAME "AMF-headers-v${VERSION}.tar.gz"
    SHA512 06fbb2269f15d9f0c98bc6158782a12d8a82e8b6a6335b42def14198476191a20ba85f72694fc91c7659ab7cec45c2a97c9e4dc3fd11c83c4ff9cdeaad33d112
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
