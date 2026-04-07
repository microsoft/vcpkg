vcpkg_download_distfile(ARCHIVE
    URLS "http://packages.seqan.de/seqan-library/seqan-library-2.4.0.zip"
    FILENAME "seqan-library-2.4.0.zip"
    SHA512 9a1b4fe9dff9ad49a8761798a6a6eaeebce683ccb5e2dd78ea4b8829093918606830a16ea458d67bf3f652531ddc55b550c12cb257be913bb187c8940d96a575
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

file(INSTALL ${SOURCE_PATH}/share/doc/seqan/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/seqan RENAME copyright)
