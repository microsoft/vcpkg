include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/nothings/stb/archive/master.zip"
    FILENAME "stb.zip"
    MD5 23bbf81dcfa7871b785e1c45d2ad24f5
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_BUILDTREES_DIR}/src/stb-master ${CURRENT_BUILDTREES_DIR}/src/stb)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/stb/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright.)

# Copy the stb header files
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/stb/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
