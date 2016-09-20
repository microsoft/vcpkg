include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://bitbucket.org/eigen/eigen/get/3.2.9.tar.bz2"
    FILENAME "eigen-3.2.9.tar.bz2"
    MD5 de11bfbfe2fd2dc4b32e8f416f58ee98
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-dc6cfdf9bcec ${CURRENT_BUILDTREES_DIR}/src/eigen)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/eigen/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen/COPYING.README)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen/copyright)

message(${CURRENT_BUILDTREES_DIR})

# Copy the eigen header files
file(COPY ${CURRENT_BUILDTREES_DIR}/src/eigen/Eigen/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Eigen/)
vcpkg_copy_pdbs()
