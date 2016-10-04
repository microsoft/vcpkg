include(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/asio-asio-1-10-6/asio/)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/chriskohlhoff/asio/archive/asio-1-10-6.zip"
    FILENAME "asio-1-10-6.zip"
    SHA512 7e3fde7e88d305d19b88482b73c8b7a41751d65e81bd23dd8ef45eb4e3ef3a10629696b4d347e5a68f08d6fb2dede15a2f38c7ee8d18ac88be769215542da4c6
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/asio-asio-1-10-6/asio/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/asio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/asio/COPYING ${CURRENT_PACKAGES_DIR}/share/asio/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")
vcpkg_copy_pdbs()
