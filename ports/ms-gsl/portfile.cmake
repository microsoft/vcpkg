#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 9d65e74400976b3509833f49b16d401600c7317d
    SHA512 36f1b0dba5b724c5ef437b07a9141f2bb2e8b059f968736e2c6d7cd5c50d5701a109df40e35f971ff8c225901560dd8783458d1f2fe56065c4cd85465cf5a527
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
