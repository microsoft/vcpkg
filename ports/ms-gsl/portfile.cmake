#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 5778149583e69b34ab375039ffcc5d51a4dd7b37
    SHA512 d59d73b09ca9f3a1be21f13437ae456eaed3378284557eac5305bd97525a2286b650ecefff2c9e8575ab3ac54351c7b82f8ddc6ac93d99d757d0d9811a378def
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
