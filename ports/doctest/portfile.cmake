#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/doctest-1.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/onqtam/doctest/archive/1.2.0.zip"
    FILENAME "doctest-1.2.0.zip"
    SHA512 7b7ee66458a9d6e43aab57cced6c5e565bec414664300d80d8d08f5a90e19ecb9685762b3462927b7ecd890bd9fb0dde53b2b034e29e559f484d328cc6403aa7
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
