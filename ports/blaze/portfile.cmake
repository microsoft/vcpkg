#header-only library
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/blaze-3.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.1.tar.gz"
    FILENAME "blaze-3.1.tar.gz"
    SHA512 fe03a7615d4105d6a869cfd69b3db3165b838eff53cdff7adbbd5ae9d753aa009bbab50925463c6704f9530a4c4ad5605e373b3cbaee96ca982a474a665ed756
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy the blaze header files
file(COPY "${SOURCE_PATH}/blaze"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
