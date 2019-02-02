#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 6418b5f4de2204cd5a335b00d2f8754301b8b382
    SHA512 d585ce18ff190e681f55c53978bd8d84dd0f8ebf0f572a49a38be07c44bd97b6d99c46b9f5fff2455dbd934e242be4a2d6d3ca2ba193358cafa14272d7a6fba8
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
