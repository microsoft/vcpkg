#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 7eb8f41af544941c712916dc0cb2c6c6ef7768ac
    SHA512 3ff9135f30f41a254728f312ca447cb574ffab5073ead29ec64c1b10b86da23e1f8bc3c67f67061793c814cd4068cdae95a64348a7de72d757be84757f699589
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
