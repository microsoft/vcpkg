#header-only library
include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/wtl/WTL%2010/WTL%2010.0.8356/WTL10_8356.zip"
    FILENAME "WTL10_8356.zip"
    SHA512 4eb24151f4009cdfebc17f08312cae65d46c8ea205ccc7b56f14c46b54d28d8d4e6290de3150e558dc076d7815a9dde2a8952695f46f4402c83b0da2bf65f241
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/Include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wtl FILES_MATCHING PATTERN "*.h")

file(COPY ${CURRENT_BUILDTREES_DIR}/src/MS-PL.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wtl/MS-PL.txt ${CURRENT_PACKAGES_DIR}/share/wtl/copyright)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/Samples DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/AppWizard DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
