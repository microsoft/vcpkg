#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF ffdaf0fb211d3a2920e480c7a8315cff98fe1b19
    SHA512 77af8ad24d15ecb1ef00bcfbea851e7f1b11a2a27ff9aedef400bd6faaa6b44b8a03f14e93a6d8beaa32b67cae0f7b2f3e63e9638998e360c99c0e287cfbd715
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
