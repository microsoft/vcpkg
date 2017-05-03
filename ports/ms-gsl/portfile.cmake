#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 8b320e3f5d016f953e55dfc7ec8694c1349d3fe4
    SHA512 79d4ecc937cdce2acf79620f12c6d4592159f17aa23c0fd1e978cc571e84ee11d91bd9a45f975546447e1ba20878244312609396a52a76f18872b97ea024aa00
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ms-gsl/LICENSE ${CURRENT_PACKAGES_DIR}/share/ms-gsl/copyright)
