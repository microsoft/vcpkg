#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF d6a2242d97827449f3f1c1c2e54214ceb9e80d62
    SHA512 d98d294e6560bc47f6b30fddf046be2a97bf9091c6e096c2c699db582d0322260c825c2357df2d2e55d017973c17798dd1d994931403534570789883f1d00321
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
