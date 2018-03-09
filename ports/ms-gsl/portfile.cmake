#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF c9e423d7cf2afb88672e31f55e4b30c53be7aae3
    SHA512 a6ea1897b931068384c0dad768202a0314f130cfc30fc6cc8307df14ac02c1842e196d87e30e85e1e3b48295f4f47780a5b3e7123937cb3c8efa9e3e10a596ed
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
