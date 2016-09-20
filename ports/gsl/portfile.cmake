include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/Microsoft/GSL/archive/fd5ad87bf25cb5e87104ee58106dee9bc809cd93.zip"
    FILENAME "gsl-fd5ad87bf.zip"
    MD5 30935befb50eb3742131ad1056d2d498
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/gsl-fd5ad87bf25cb5e87104ee58106dee9bc809cd93/gsl DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*")

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/gsl-fd5ad87bf25cb5e87104ee58106dee9bc809cd93/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gsl/LICENSE ${CURRENT_PACKAGES_DIR}/share/gsl/copyright)
