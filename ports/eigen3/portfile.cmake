include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-dc6cfdf9bcec)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.2.9.tar.bz2"
    FILENAME "eigen-3.2.9.tar.bz2"
    SHA512 2734ce70e0b04dc5839715a3cc9b8f90e05b341cfca42a7d586df213a9a14fe5642c76ccf36c16d020ae167c0d6e4d5cc306f0b3bf1f519c58372b0736ca7e63
)
vcpkg_extract_source_archive(${ARCHIVE})

file(GLOB_RECURSE GARBAGE ${SOURCE_PATH}/Eigen/CMakeLists.*)
if(GARBAGE)
    file(REMOVE ${GARBAGE})
endif()

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen3/copyright)

# Copy the eigen header files
file(COPY ${SOURCE_PATH}/Eigen/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Eigen/)
vcpkg_copy_pdbs()
