include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/miloyip/rapidjson/archive/879def80f2e466cdf4c86dc7e53ea2dd4cafaea0.zip"
    FILENAME "rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0.zip"
    SHA512 4d9ef7cce7d179344c33245c081a142ca5fcb2a0cc170ed39e3d0add008efab8e7389feec03e1ea83b30c5778cd0600865b08bc1c23592e5154dbe1f21f9547d
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${CURRENT_BUILDTREES_DIR}/src/rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)

# Copy the rapidjson header files
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
