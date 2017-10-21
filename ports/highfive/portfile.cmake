include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/HighFive-1.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/BlueBrain/HighFive/archive/v1.3.tar.gz"
    FILENAME "highfive.v1.3.tar.gz"
    SHA512 258efae1ef5eed45ac1cf93c21c79fab9ee3c340d49a36a4aa2b43c98df1c80db9167a40a0b6a59c4f99b7c190d41d545b53c0f2c5c59aabaffc4b2584b4390b
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy the highfive header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/highfive RENAME copyright)
