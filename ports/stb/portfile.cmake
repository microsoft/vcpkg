include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/nothings/stb/archive/e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    FILENAME "stb-e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    MD5 5d81d3036610045d5a8076728c4e2f7e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_BUILDTREES_DIR}/src/stb-e713a69f1ea6ee1e0d55725ed0731520045a5993 ${CURRENT_BUILDTREES_DIR}/src/stb)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/stb/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright)

# Copy the stb header files
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/stb/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
