include(winports_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/miloyip/rapidjson/archive/879def80f2e466cdf4c86dc7e53ea2dd4cafaea0.zip"
    FILENAME "rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0.zip"
    MD5 5394c3bc23177b000e1992fb989edc53
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${CURRENT_BUILDTREES_DIR}/src/rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)

# Copy the rapidjson header files
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/rapidjson-879def80f2e466cdf4c86dc7e53ea2dd4cafaea0/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
