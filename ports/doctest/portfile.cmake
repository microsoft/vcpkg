#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/doctest-1.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/onqtam/doctest/archive/1.1.0.zip"
    FILENAME "doctest-1.1.0.zip"
    SHA512 3cbdbb82d2dceff5a34aaed45222832c5767f21b64b271c41c2da7bae1f9e364a60758a8b6ce64285999afc30dd76de980e287663fa3119d0bcc1d2b45514e0b
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
