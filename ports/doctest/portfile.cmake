include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/onqtam/doctest/archive/1.1.0.zip"
    FILENAME "doctest-1.1.0.zip"
    MD5 4aee74025b34b4a00a253b6262bdeeb1
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle copyright
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/doctest-1.1.0/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/doctest-1.1.0/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
