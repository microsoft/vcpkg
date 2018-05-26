#header-only library
include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/wtl/WTL%2010/WTL%2010.0.7336/WTL10_7336.zip"
    FILENAME "WTL10_7336.zip"
    SHA512 68368be0b35fba97ed63fd684e98c077ab94ea2ce928693da7f1f48e2547486109e045e026218a7c8652aec46930b79572679c0b79afaa75a3dbf98572e4d9b5
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/Include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wtl FILES_MATCHING PATTERN "*.h")

file(COPY ${CURRENT_BUILDTREES_DIR}/src/MS-PL.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wtl/MS-PL.txt ${CURRENT_PACKAGES_DIR}/share/wtl/copyright)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/Samples DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/AppWizard DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
