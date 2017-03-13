#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-67e894c6cd8f)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.3.3.tar.bz2"
    FILENAME "eigen-3.3.3.tar.bz2"
    SHA512 bb5a8b761371e516f0a344a7c9f6e369e21c2907c8548227933ca6010fc607a66c8d6ff7c41b1aec3dea7d482ce8c2a09e38ae5c7a2c5b16bdd8007e7a81ecc3
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
