include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.2.9.tar.bz2"
    FILENAME "eigen-3.2.9.tar.bz2"
    SHA512 2734ce70e0b04dc5839715a3cc9b8f90e05b341cfca42a7d586df213a9a14fe5642c76ccf36c16d020ae167c0d6e4d5cc306f0b3bf1f519c58372b0736ca7e63
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-dc6cfdf9bcec ${CURRENT_BUILDTREES_DIR}/src/eigen)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/eigen/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen3/copyright)

file(GLOB_RECURSE GARBAGE ${CURRENT_BUILDTREES_DIR}/src/eigen/Eigen/CMakeLists.*)
file(REMOVE ${GARBAGE})

# Copy the eigen header files
file(COPY ${CURRENT_BUILDTREES_DIR}/src/eigen/Eigen/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Eigen/)
vcpkg_copy_pdbs()
