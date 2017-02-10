#header-only library
include(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/asio-asio-1-10-8/asio/)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/chriskohlhoff/asio/archive/asio-1-10-8.zip"
    FILENAME "asio-1-10-8.zip"
    SHA512 bc9794a20fc7844a2a9d22bfa418005f61defbcecdd612daba0d317e6f8fc5a61d3a3b2d7d557b92584294b8adfccc3c47a8f0441f3e34a47a0f715ca1ba0e5b
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/asio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/asio/COPYING ${CURRENT_PACKAGES_DIR}/share/asio/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")
