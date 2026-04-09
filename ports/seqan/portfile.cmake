vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/seqan/seqan/releases/download/seqan-v${VERSION}/seqan-library-${VERSION}.zip"
    FILENAME "seqan-library-${VERSION}.zip"
    SHA512 de62c69bfacf758df8f3dde11a12f4f54b145e18da8aba859f5e4a569f8969aa45a3dd5db6dda0b0970bb8bc088804ceb7a80ec4a85cea0c97a6d437851801e1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

file(INSTALL ${SOURCE_PATH}/share/doc/seqan/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/seqan RENAME copyright)
