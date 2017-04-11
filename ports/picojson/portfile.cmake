
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/picojson-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/kazuho/picojson/archive/master.zip"
    FILENAME "picojson-1.3.1.zip"
    SHA512 961138c1233ee960c8810cd0e53af27b42956ec0ed4017085b2330417833f91ba728dd76e64ece019a37eb5f8a857cc57d36c3370a27707d995091ab409c4819
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/picojson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/picojson/LICENSE ${CURRENT_PACKAGES_DIR}/share/picojson/copyright)

# Copy the header files
file(INSTALL ${SOURCE_PATH}/picojson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/picojson)

vcpkg_copy_pdbs()
