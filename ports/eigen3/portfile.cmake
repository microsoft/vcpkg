include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-dc6cfdf9bcec)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.2.10.tar.bz2"
    FILENAME "eigen-3.2.10.tar.bz2"
    SHA512 413c01a5b1b5d2e4366bc9289b1d613b21157e702b1c0d544e41ba5726acfbe0b60921ded37926010e9ce3642939e3ad39038e053d392b90a7a6302955ec5058
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
