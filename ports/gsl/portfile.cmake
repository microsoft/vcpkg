include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gsl-fd5ad87bf25cb5e87104ee58106dee9bc809cd93)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/GSL/archive/fd5ad87bf25cb5e87104ee58106dee9bc809cd93.zip"
    FILENAME "gsl-fd5ad87bf.zip"
    SHA512 81887be57e12bfc4e67353713478e1638bf1bffb8f523cf7241acf5415c2e3fe82ea0c0128380dcb2008afb5f53ac0d4893660626a8cd1eb501da536e6af5692
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/gsl DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsl/LICENSE ${CURRENT_PACKAGES_DIR}/share/gsl/copyright)
