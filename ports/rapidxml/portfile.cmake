include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://sourceforge.net/projects/rapidxml/files/rapidxml/rapidxml%201.13/rapidxml-1.13.zip/download"
    FILENAME "rapidxml-1.13.zip"
    MD5 7b4b42c9331c90aded23bb55dc725d6a
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/rapidxml-1.13/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidxml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidxml/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidxml/copyright)

# Copy the header files
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/rapidxml-1.13/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")
