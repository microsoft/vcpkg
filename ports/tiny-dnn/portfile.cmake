#header-only library
include(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tiny-dnn-dd906fed8c8aff8dc837657c42f9d55f8b793b0e)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/dd906fed8c8aff8dc837657c42f9d55f8b793b0e.zip"
    FILENAME "tiny-dnn-1.zip"
    SHA512 9881d5a10215e3e2e5fe0e3df6b061ebf4e5c064883bdcff5578f1b635c6a41e8f03bfbcf7e07922f3c477c3bdfb5dea85d616e2cd9d42f07d7ae78e601ffded
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include)


file(COPY ${CURRENT_BUILDTREES_DIR}/src/tiny-dnn-dd906fed8c8aff8dc837657c42f9d55f8b793b0e/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)