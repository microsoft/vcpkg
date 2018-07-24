include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 9.0.1
    SHA512 4c7cda31c49afffd2ade97481eb47455c58d9d4ba1015661e08abe0b9db34f7d69ea9bd932f792b8bd2f6c92d38dc30e2a64b8ff34b4c4204b8da2260c15ae66
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
