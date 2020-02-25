include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF 96de8f7a519b61abd4ef53ec37cd89565880aa50 # v2.7
    SHA512 6b65faaccf751ca5c4b695513205c1aa60966f438e912dbacbcb60eeb517aab091a6787a1e9df562ef100ffc2b341640bab05ae76be7c4e60c7d92fd2b5fddd6
    HEAD_REF master
)

# Install header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctre RENAME copyright)
