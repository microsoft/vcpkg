#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-26667be4f70b)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.3.0.tar.bz2"
    FILENAME "eigen-3.3.0.tar.bz2"
    SHA512 a1919accc9fcf64eca17b3e60a78eefeb1a187c261c28b8480604f36cf366cd6323e966d6b948f8a4ce0ae3213a3815bccd34661d1d8fb33315def4304bf163e
)
vcpkg_extract_source_archive(${ARCHIVE})

file(GLOB_RECURSE GARBAGE ${SOURCE_PATH}/Eigen/CMakeLists.* ${SOURCE_PATH}/unsupported/Eigen/CMakeLists.*)
if(GARBAGE)
    file(REMOVE ${GARBAGE})
endif()

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen3/copyright)

# Copy the eigen header files
file(COPY ${SOURCE_PATH}/Eigen ${SOURCE_PATH}/signature_of_eigen3_matrix_library
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/unsupported/Eigen
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/unsupported)

# Copy signature file so tools can locate the eigen headers
file(COPY DESTINATION ${CURRENT_PACKAGES_DIR}/include)
