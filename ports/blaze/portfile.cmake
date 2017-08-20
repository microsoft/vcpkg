#header-only library
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/blaze-3.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/blaze-lib/blaze/downloads/blaze-3.2.tar.gz"
    FILENAME "blaze-3.2.tar.gz"
    SHA512 33d2bb0a49a33e71c88a45ab9e8418160c09b877b3ebe5ff7aa48ec0973e28e8a282374604d56f1b5cf2722946e4ca84aa2b401a341240a2ab9debd72505148e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy the blaze header files
file(COPY "${SOURCE_PATH}/blaze"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
